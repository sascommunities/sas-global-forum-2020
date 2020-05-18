
import swat
import pandas as pd
import numpy as np
from IPython.display import display, Image
from IPython.display import HTML
from graphviz import Digraph, Graph
import os.path
from itertools import islice

class AttributeDict(dict):
    __getattr__ = dict.__getitem__
    __setattr__ = dict.__setitem__

# Definition of Globals
randomSeed = 123
trainPercentage = 80
nClasses = 7
nWords = 1433
targetColumn = 'target'
baseFeatureList = [f"w{i}" for i in range(1,nWords+1)]

targetClassFmt = "$targetClass"

class Demo():
   """
    A wrapper class holding the function definitions related to this demo.

    ...

    Attributes
    ----------
    s : swat.cas.s.connection.CAS
        a connection to a CAS session
    """

   def __init__(self, s):
      self.s = s
      self.loadedGraph = None
      self.s.loadactionset(actionset="sampling")
      self.s.loadactionset(actionset='pca')
      self.s.loadactionset(actionset="fedsql")
      self.s.loadactionset(actionset="deepLearn")
      self.s.loadactionset(actionset="network")
      self.s.loadactionset(actionset="transpose")
      self.s.loadactionset(actionset="table")
      self.s.loadactionset(actionset="builtins")
      self.s.loadactionset(actionset="neuralNet")
      self.s.loadactionset(actionset="autotune")
      self.s.loadactionset(actionset="session")
      self.s.loadactionset(actionset="decisionTree")
      self.s.loadactionset(actionset="aStore")
      self.s.loadactionset(actionset="aggregation")
   
   def loadRawData(self,
                   pathCoraContent="../data/cora.content",
                   pathCoraCites="../data/cora.cites"
                  ):
      contentDf = pd.read_csv(pathCoraContent, sep="\t", header=None)
      contentDf.rename(columns=(lambda x: f"w{x}"), inplace=True)
      contentDf.rename(columns={"w0": "node", "w1434": "target"}, inplace=True)
      self.s.upload(contentDf, casout={"name": "content", "replace": True})

      citesDf = pd.read_csv(pathCoraCites, sep="\t", header=None)
      citesDf.rename(columns={0:"from",1:"to"}, inplace=True)
      self.s.upload(citesDf, casout={"name": "cites", "replace": True})
   
   def head(self, table, nRows=5):
      return self.s.table.fetch(table=table, format=True, to=nRows, maxRows=nRows)

   def defineTargetVariableFormat(self):
      """Custom Format Definition for Target Labels."""
      self.s.sessionProp.addFmtLib(
         fmtLibName="myFmtLib",
         caslib="mycas",
         replace=True
      )
      self.s.sessionProp.addFormat(
         fmtLibName="myFmtLib",
         fmtName=targetClassFmt,
         replace=True,
         ranges={"'Case_Based'='1'",
                  "'Genetic_Algorithms'='2'",
                  "'Neural_Networks'='3'",
                  "'Probabilistic_Methods'='4'",
                  "'Reinforcement_Learning'='5'",
                  "'Rule_Learning'='6'",
                  "'Theory'='7'",
                  "' '=' '" 
               })
   
   def addCaslibIfNeeded(self, caslib):
      r = self.s.table.queryCaslib(caslib=caslib)
      if not r[caslib]:
         self.s.table.addcaslib(
            activeOnAdd=False,
            caslib="cora",
            datasource={"srctype":"path"},
            path="/bigdisk/lax/brrees/data/cora"
         )
   
   def saveTables(self, tables, caslib="cora", replace=True, fmt=None):
      for table in tables:
         self.s.table.save(
               caslib=caslib,
               table=table,
               name=f"{table}.sashdat" if fmt is None else f"{table}.{fmt}".lower(),
               replace=replace
            )
   
   def loadTables(self, tables, caslib="cora", fmt=None):
      for table in tables:
         self.s.table.loadTable(
            caslib=caslib,
            casOut={"name":table, "replace":True},
            path=f"{table}.sashdat" if fmt is None else f"{table}.{fmt}".lower()
         )
   
   def partitionData(self,
                     tableIn="content",
                     tableOut="contentPartitioned", 
                     table1Out="contentTrain", 
                     table2Out="contentTest", 
                     frac1=trainPercentage, 
                     randomSeed=randomSeed,
                     partName="partition"
                     ):
      self.s.sampling.srs(
         table=tableIn,
         seed=randomSeed,
         samppct=frac1,
         partInd=True,
         output={
            "casout":{"name":tableOut, "replace":True},
            "copyVars":"all",
            "partIndName":partName
         }
      )

      if table1Out is not None:
         self.s.datastep.runCode(
            code = f"""
               data {table1Out};
                  set {tableOut}(where=({partName}=1));
               run;
            """
         )
      if table2Out is not None:
         self.s.datastep.runCode(
            code = f"""
               data {table2Out};
                  set {tableOut}(where=({partName}=0));
                  run;
            """
         )


   def loadOrPartitionData(self, newRun=False):
      coraCaslib="cora"
      self.addCaslibIfNeeded(coraCaslib)
      
      tablePartitioned="contentPartitioned.sashdat"
      r = self.s.table.fileInfo(caslib=coraCaslib)
      if not tablePartitioned in r.FileInfo["Name"].unique():
         newRun = True

      if newRun:
         self.partitionData()
         self.saveTables(["contentPartitioned", "contentTrain", "contentTest"])
      else:
         self.loadTables(["contentPartitioned", "contentTrain", "contentTest"])
   
   def performPca(self, nPca):
      self.nPca = nPca
      self.s.pca.eig(
         table="contentTrain",
         n=nPca,
         prefix="pca",
         inputs=baseFeatureList,
         code={
            "casOut":{"name":"pcaTransformCode", "replace":True},
            "comment":False,
            "tabForm":True
         },
         output={"casOut":{"name":"contentTrainPca", "replace":True},
                  "copyVars":["node", "target", "partition"],
                  "score":"pca"}
      )
      self.s.datastep.runCodeTable(
         table="contentPartitioned",
         codeTable="pcaTransformCode",
         casout={"name":"contentPartitionedPca"},
         dropVars=baseFeatureList
      )
      self.s.datastep.runCode(
         code = "data contentTestPca; set contentPartitionedPca(where=(partition=0)); run;"
      )

   def joinTrainingTargets(self):
      self.s.fedsql.execDirect(
         query = """
      create table citesTrain {options replace=true} as
      select a.*, b.target as from_target, c.target as to_target
      from cites as a
      inner join contentTrain as b
      on a.from = b.node
      inner join contentTrain as c
      on a.to = c.node;
         """
      )
      self.s.fedsql.execDirect(
         query = """
      create table citesCombined {options replace=true} as
      select a.*, b.target as from_target, c.target as to_target
      from cites as a
      left join contentTrain as b
      on a.from = b.node
      left join contentTrain as c
      on a.to = c.node;
         """
      )

   def defineNnModel(self, modelName, deepLearnParam):
      self.s.deepLearn.buildModel(
         modelTable={"name": modelName, "replace": True},
         type="DNN"
      )

      # Add the input layer
      self.s.deepLearn.addLayer(
         modelTable={"name": modelName},
         layer={"type": "INPUT"},
         name="inputLayer"
      )

      # Add the dense (a.k.a. fully connected) layers
      prevLayer = "inputLayer"
      for i in range(len(deepLearnParam.denseLayers)):
         thisLayer = f"denseLayer{i}"
         self.s.deepLearn.addLayer(
               modelTable={"name": modelName},
               layer={"type": "FC",
                     "n": deepLearnParam.denseLayers[i],
                     "act": deepLearnParam.activation,
                     "dropout": deepLearnParam.dropout},
               name=thisLayer,
               srcLayers=[prevLayer]
         )
         prevLayer = thisLayer

      # Add the output layer
      self.s.deepLearn.addLayer(
         modelTable={"name": modelName},
         layer={"type": "OUTPUT",
                  "n": deepLearnParam.nOutputs,
                  "act": deepLearnParam.outputActivation},
         name="outputLayer",
         srcLayers=[prevLayer]
      )
   
   def trainNnModel(self, modelName, tableTrain, featureList, deepLearnParam):
      return self.s.deepLearn.dlTrain(
         seed=deepLearnParam.randomSeed,
         inputs=featureList,
         target=targetColumn,
         table=tableTrain,
         modelTable=modelName,
         optimizer={"algorithm":{"method":deepLearnParam.algoMethod, "useLocking":deepLearnParam.useLocking},
                     "maxEpochs":deepLearnParam.nEpochs},
         modelWeights={"name":f"{modelName}Weights", "replace":True}
      )
   
   def tuneNnModel(self, modelName, tableTrain, tableValid, featureList, deepLearnParam, tuneIter=15):
      return self.s.deepLearn.dlTune(
         seed=deepLearnParam.randomSeed,
         inputs=featureList,
         target=targetColumn,
         table=tableTrain,
         validTable=tableValid,
         modelTable=modelName,
         optimizer={"algorithm":{"method":deepLearnParam.algoMethod, "useLocking":deepLearnParam.useLocking},
                     "maxEpochs":deepLearnParam.nEpochs,
                     "dropout":{"logScale": False, "lowerBound":0.2, "upperBound":0.6, "value":0.5},
                     "regL1":{"logScale": True, "lowerBound":0, "upperBound":1.0e-6, "value":2.29262E-7},
                     "regL2":{"logScale": True, "lowerBound":0, "upperBound":1.0e-7, "value":0.0},
                     "tuneIter":tuneIter
                   },
         modelWeights={"name":f"{modelName}Weights_", "replace":True},
         bestWeights={"name":f"{modelName}Weights", "replace":True}
      )
   
   def scoreNnModel(self, modelName, tableTest, silent=False):
      r = self.s.deepLearn.dlScore(
         initWeights=f"{modelName}Weights",
         table=tableTest,
         modelTable=modelName,
         copyVars=("node", "target"),
         # bufferSize=1,
         casOut={"name":f"{modelName}Scored", "replace":True}
      )
      accuracy = (100-float(r.ScoreInfo["Value"][2]))/100
      if not silent:
         print(r.ScoreInfo)
         print(f"Accuracy = {accuracy}")
      return accuracy
   
   
   def bootstrapNnModel(self, modelName, tableTrain, tableTest, featureList, deepLearnParam, n):
      accuracies = []
      for i in range(n):
         self.partitionData(tableIn=tableTest, tableOut=f"{tableTest}Part_", table1Out=f"{tableTest}Boot_", table2Out=None, frac1=90, randomSeed=(i+5678), partName="bootstrap")
         self.trainNnModel(modelName, tableTrain, featureList, deepLearnParam)
         acc=self.scoreNnModel(modelName, f"{tableTest}Boot_", silent=True)
         print(f"Accuracy = {acc}")
         accuracies = accuracies + [acc]
      
      print(f"Bootstrap Accuracy = {np.mean(accuracies)} +- {np.std(accuracies)}")
      return accuracies

   def bootstrapAnnModel(self, modelName, tableTrain, tableTest, featureList, deepLearnParam, annParam, n):
      accuracies = []
      for i in range(n):
         self.partitionData(tableIn=tableTest, tableOut=f"{tableTest}Part_", table1Out=f"{tableTest}Boot_", table2Out=None, frac1=90, randomSeed=(i+5678), partName="bootstrap")
         self.trainAnnModel(modelName, tableTrain, featureList, deepLearnParam, annParam)
         acc=self.scoreAnnModel(modelName, f"{tableTest}Boot_", True)
         print(f"Accuracy = {acc}")
         accuracies = accuracies + [acc]
      
      print(f"Bootstrap Accuracy = {np.mean(accuracies)} +- {np.std(accuracies)}")
      return accuracies
   
   def trainAnnModel(self, modelName, tableTrain, featureList, deepLearnParam, annParam=None):
      if annParam is None:
         return self.s.neuralNet.annTrain(
            modelId=modelName,
            seed=deepLearnParam.randomSeed,
            inputs=featureList,
            target=targetColumn,
            nominal={targetColumn},
            table=tableTrain,
            hiddens=deepLearnParam.denseLayers,
            # acts={deepLearnParam.activation, deepLearnParam.activation},
            # targetAct=deepLearnParam.outputActivation,
            dropout=deepLearnParam.dropout,
            scaleInit=1,
            # randDist="CAUCHY" | "MSRA" | "NORMAL" | "UNIFORM" | "XAVIER",
            randDist="CAUCHY",
            nTries=30,
            nAnns=7,
            nloOpts={
               "algorithm":deepLearnParam.algoMethod,
               "optmlOpt":{"maxIters":16, "fConv":1e-10}
            },
            casOut={"name":f"{modelName}Weights", "replace":True}
         )
      nHidden = self.getParamValue(annParam, "nHidden", int)
      hiddens = [self.getParamValue(annParam, f"nUnits{i+1}", int) for i in range(nHidden)]
      regL1 = self.getParamValue(annParam, "regL1")
      regL2 = self.getParamValue(annParam, "regL2")
      return self.s.neuralNet.annTrain(
         modelId=modelName,
         seed=deepLearnParam.randomSeed,
         inputs=featureList,
         target=targetColumn,
         nominal={targetColumn},
         table=tableTrain,
         hiddens=hiddens,
         dropout=deepLearnParam.dropout,
         # acts={deepLearnParam.activation, deepLearnParam.activation},
         # targetAct=deepLearnParam.outputActivation,
         # scaleInit=1,
         # randDist="CAUCHY" | "MSRA" | "NORMAL" | "UNIFORM" | "XAVIER",
         randDist="CAUCHY",
         nTries=30,
         nAnns=7,
         nloOpts={
            "algorithm":deepLearnParam.algoMethod,
            "optmlOpt":{"maxIters":16, "fConv":1e-10,
                        "regL1":regL1,
                        "regL2":regL2
                       }
            # , "sgdOpt":{"seed": deepLearnParam.randomSeed}
         },
         casOut={"name":f"{modelName}Weights", "replace":True}
      )

   def scoreAnnModel(self, modelName, tableTest, silent=False):
      r = self.s.neuralNet.annScore(
         table=tableTest,
         modelTable=f"{modelName}Weights",
         copyVars=("node", "target"),
         casOut={"name":f"{modelName}Scored", "replace":True}
      )
      accuracy = (100-float(r.ScoreInfo["Value"][2]))/100
      if not silent:
         print(r.ScoreInfo)
         print(f"Accuracy = {accuracy}")
      return accuracy
   
   def initNetwork(self, tableName):
      # Copies the base feature table and returns an empty network features list
      self.s.datastep.runCode(
         code=f"data {tableName}Network; set {tableName}; run;"
      )
      featureList=[];
      return featureList
   
   def loadGraph(self, tableNodes, tableLinks):
    # Load an in-memory copy of the graph represented by the nodes and links tables
      r = self.s.network.loadGraph(
         loglevel="NONE",
         multilinks=False,
         links=tableLinks,
         nodes={"name":tableNodes,
               "computedVars": ("initialCommunity"),
               "computedVarsProgram": "initialCommunity = input(put(target, $targetClass.), 1.);"
               },
         nodesVar={"vars":("initialCommunity")}
      )
      return r.graph
   
   def unloadGraph(self, graphId):
      r = self.s.network.unloadGraph(
         graph=graphId
      )
      return None
   
   def mergeFeatures(self, tableNodes, tableNodesAdd, featureList, featureListAdd):
    self.s.datastep.runCode(
        code=f"""
            data {tableNodes};
                merge {tableNodes} {tableNodesAdd};
                by node;
            run;
        """
    )
    featureList = featureList + featureListAdd
    return featureList
   
   def mergeRatioFeature(self, tableNodes, tableNodesAdd, featureList, featureAdd, denominator):
      self.s.datastep.runCode(
         code=f"""
            data {tableNodes};
                  merge {tableNodes} {tableNodesAdd};
                  by node;
                  if ({denominator} GT 0) then {featureAdd} = {featureAdd}/{denominator};
                  else {featureAdd}=0;
            run;
         """
      )
      featureList = featureList + [featureAdd]
      return featureList
   
   def addFeaturesNodeSimilarity(self, graphId, tableNodes, featureList):
      nDimensions=10
      outTableNodes="outNodesNodeSim"
      self.s.network.nodesimilarity(
         loglevel="BASIC",
         graph=graphId,
         jaccard=False,
         vector=True,
         proximityOrder="second",
         nDimensions=nDimensions,
         nSamples=500000,
         convergenceThreshold=0.0001,
         outNodes={"name":outTableNodes, "replace":True}
      )
      newFeatures=[f"vec_{i}" for i in range(nDimensions)]+[f"ctx_{i}" for i in range(nDimensions)]
      featureList = self.mergeFeatures(tableNodes, outTableNodes, featureList, newFeatures)
      return featureList
   
   def addFeaturesCore(self, graphId, tableNodes, tableLinks, featureList):
      nDimensions=10
      outTableNodes="outNodesCore"
      self.s.network.core(
         loglevel="NONE",
         graph=graphId,
         outNodes={"name":outTableNodes, "replace":True}
      )
      newFeatures=["core_out"]
      featureList = self.mergeFeatures(tableNodes, outTableNodes, featureList, newFeatures)

      subgraphs=["Case_Based",
               "Genetic_Algorithms",
               "Neural_Networks",
               "Probabilistic_Methods",
               "Reinforcement_Learning",
               "Rule_Learning",
               "Theory"
               ]

      for subgraph in subgraphs:
         self.s.network.core(
            loglevel="NONE",
            nodes=tableNodes,
            links={"name":tableLinks, "where":f"from_target EQ '{subgraph}' OR to_target EQ '{subgraph}'"},
            outNodes={"name":outTableNodes, "replace":True}
         )
         newFeature="core_out_"+subgraph
         featureList = self.mergeRatioFeature(tableNodes, outTableNodes+f"(rename=(core_out={newFeature}))", featureList, newFeature,"core_out")
      return featureList
   
   def addFeaturesCentrality(self, tableNodes, tableLinks, featureList):
      outTableNodes="nodesCentrality"
      outTableTransIn="nodesDegreeIn"
      outTableTransOut="nodesDegreeOut"

      self.s.network.centrality(
         loglevel="NONE",
         direction="directed",
         links={"name":tableLinks, "where":"FROM_TARGET NE ' '", "groupBy":"FROM_TARGET"},
         outNodes={"name":outTableNodes, "replace":True},
         degree="unweight"
      )
      self.s.transpose.transpose(
         table={"name":outTableNodes, "groupBy":"node"},
         transpose=("centr_degree_in"),
         id=("FROM_TARGET"),
         prefix="deg_in_",
         casOut={"name":outTableTransIn, "replace":True}
      )

      self.s.network.centrality(
         loglevel="NONE",
         direction="directed",
         links={"name":tableLinks, "where":"to_target NE ' '", "groupBy":"to_target"},
         outNodes={"name":outTableNodes, "replace":True},
         degree="unweight"
      )
      self.s.transpose.transpose(
         table={"name":outTableNodes, "groupBy":"node"},
         transpose=("centr_degree_out"),
         id=("to_target"),
         prefix="deg_out_",
         casOut={"name":outTableTransOut, "replace":True}
      )
      tableNetworkDegree="networkDegree"
      self.s.datastep.runCode(
         code = f"""
            data networkDegree;
                  merge {tableNodes}(keep=node)
                        {outTableTransIn}(drop=_NAME_)
                        {outTableTransOut}(drop=_NAME_);
                  by node;
                  array x deg_: ;
                  do over x;
                     if x=. then x=0;
                  end;
            run;
         """
      )
      r = self.s.table.columnInfo(
         table=tableNetworkDegree
      )
      newFeatures = r["ColumnInfo"]['Column'].tolist()[1:]
      featureList = self.mergeFeatures(tableNodes, tableNetworkDegree, featureList, newFeatures)
      return featureList
   
   def addFeaturesCommunity(self, graphId, tableNodes, featureList):
      outTableNodes="outNodesCommunity"
      outTableComm="outComm"
      outTableOverlap="OutCommOverlap"
      self.s.network.community(
         loglevel="NONE",
         graph=graphId,
         warmstart="initialCommunity",
         resolutionList = (1.0, 0.2),
         outNodes={"name":outTableNodes, "replace":True}
      )
      self.s.network.community(
         loglevel="NONE",
         graph=graphId,
         warmstart="initialCommunity",
         resolutionList = (1.0),
         outCommunity={"name":outTableComm, "replace":True},
         outOverlap={"name":outTableOverlap, "replace":True}
      )
      self.s.fedsql.execDirect(
         query=f"""
            create table {outTableNodes} {{options replace=true}} as
            select a.*, b.nodes as "commNodes",
                     b.conductance as "commConductance",
                     b.density as "commDensity",
                     COALESCE(c.intensity, 0) as "commIntensity"
            from {outTableNodes} as a
            left join {outTableComm} as b
            on a.community_0 = b.community and b.level = 0
            left join {outTableOverlap} as c
            on a.node=c.node and a.community_0 = c.community
            ;
         """
      )
      newFeatures=["commNodes", "commConductance", "commDensity", "commIntensity"]
      featureList = self.mergeFeatures(tableNodes, outTableNodes, featureList, newFeatures)
      return featureList
   
   def addNetworkFeatures(self, tableInitNodes, tableLinks, networkParam):
      tableNodes = f"{tableInitNodes}Network"
      featureList = self.initNetwork(tableInitNodes)
      # self.s.builtins.log(logger = "", level = "WARN")
      if self.loadedGraph is None:
         self.loadedGraph=self.loadGraph(tableInitNodes, tableLinks)
      if networkParam.useCommunity:
         featureList = self.addFeaturesCommunity(self.loadedGraph, tableNodes, featureList)
      if networkParam.useCentrality:
         featureList = self.addFeaturesCentrality(tableNodes, tableLinks, featureList)
      if networkParam.useNodeSimilarity:
         featureList = self.addFeaturesNodeSimilarity(self.loadedGraph, tableNodes, featureList)
      if networkParam.useCore:
         featureList = self.addFeaturesCore(self.loadedGraph, tableNodes, tableLinks, featureList)
      if self.loadedGraph is not None:
         self.unloadGraph(self.loadedGraph)
         self.loadedGraph=None;
      # self.s.builtins.log(logger = "", level = "INFO")
      return (tableNodes, featureList)
   
   def getParamValue(self, paramsDf, paramName, castType=float):
      return castType(paramsDf.loc[paramName.upper(), "Value"])

   def trainForestModel(self, modelName, tableTrain, featureList, randomSeed=12345, forestParam=None):
      if forestParam is None:
         return self.s.decisionTree.forestTrain(
            inputs=featureList,
            target=targetColumn,
            nominal={targetColumn},
            table=tableTrain,
            varImp=True,
            seed=randomSeed,
            casOut={"name":modelName, "replace":True},
            saveState={"name":f"{modelName}AStore", "replace":True}
         )
      else:
         return self.s.decisionTree.forestTrain(
            inputs=featureList,
            target=targetColumn,
            nominal={targetColumn},
            table=tableTrain,
            varImp=True,
            seed=randomSeed,
            nTree=self.getParamValue(forestParam, "nTree"),
            M=self.getParamValue(forestParam, "M"),
            bootstrap=self.getParamValue(forestParam, "bootstrap"),
            maxLevel=self.getParamValue(forestParam, "maxLevel"),
            nBins=self.getParamValue(forestParam, "nBins"),
            casOut={"name":modelName, "replace":True},
            saveState={"name":f"{modelName}AStore", "replace":True}
         )

   
   def scoreForestModel(self, modelName, tableTest, silent=False):
      r = self.s.aStore.score(
         table=tableTest,
         rstore=f"{modelName}AStore",
         copyVars={"node", "target"},
         casout={"name":f"{modelName}Scored", "replace":True}
      )
      tbl=self.s.CASTable(f"{modelName}Scored")
      accuracy = sum(tbl["I_target"]==tbl["target"]) /  len(tbl)
      if not silent:
         print(f"Accuracy = {accuracy}")
      return accuracy

      
   def bootstrapForestModel(self, modelName, tableTrain, tableTest, featureList, forestParam=None, n=25):
      accuracies = []
      for i in range(n):
         self.partitionData(tableIn=tableTest, tableOut=f"{tableTest}Part_", table1Out=f"{tableTest}Boot_", table2Out=None, frac1=90, randomSeed=(i+5678), partName="bootstrap")
         self.trainForestModel(modelName, tableTrain, featureList, randomSeed=(12345+i), forestParam=forestParam)
         acc=self.scoreForestModel(modelName, f"{tableTest}Boot_")
         accuracies = accuracies + [acc]
      
      print(f"Bootstrap Accuracy = {np.mean(accuracies)} +- {np.std(accuracies)}")
      return accuracies

   def tuneAnnModel(self, modelName, tableTrain, featureList, tunerOptions=None, tuningParameters=None): 
      if tunerOptions is None:
         tunerOptions={
            "seed":123,
            "objective":"MISC"
         }
      if tuningParameters is None:
         tuningParameters=[{"namePath":"nHidden", "initValue":2, "valueList":[1,2]}
                          ,{"namePath":"annealingRate", "exclude":True}
                          ,{"namePath":"learningRate", "exclude":True}
                          ,{"namePath":"regL2", "upperBound":0.00001, "initValue":0}
                          ,{"namePath":"regL1", "upperBound":0.000001, "initValue":0}
                          ,{"namePath":"nUnits1", "lowerBound": 10, "upperBound":199, "initValue":50}
                          ,{"namePath":"nUnits2", "lowerBound": 10, "upperBound":99, "initValue":50}
         ]
      result = self.s.autotune.tuneNeuralNet(
         trainOptions = {
            "table" : tableTrain,
            "inputs": featureList,
            "target": targetColumn,
            "nominal": {targetColumn},
            "dropout": 0.5,
            "scaleInit": 1,
            "randDist": "CAUCHY",
            "nTries": 3,
            "nAnns": 1,
            "nloOpts":{
               "algorithm":"ADAM",
               "optmlOpt":{"maxIters":16, "fConv":1e-10}
            },
            "casOut":{"name":f"{modelName}Weights", "replace":True}
         },
         tunerOptions=tunerOptions,
         tuningParameters=tuningParameters
      )
      return result

   def tuneForestModel(self, modelName, tableTrain, featureList, tunerOptions=None): 
      if tunerOptions is None:
         tunerOptions={
            "seed":123,
            "objective":"MISC"
         }
      result = self.s.autotune.tuneForest(
         trainOptions = {
            "table" : tableTrain,
            "inputs": featureList,
            "target": targetColumn,
            "nominal" : {targetColumn},
            "casout": {"name":modelName, "replace":True},
            "saveState": {"name":f"{modelName}AStore", "replace":True}
         },
         tunerOptions=tunerOptions
      )
      return result
   
   def loadOrTuneAnnModel(self, modelName, tableTrain, featureList, tunerOptions=None, tuningParameters=None, newRun=False): 
      coraCaslib="cora"
      self.addCaslibIfNeeded(coraCaslib)

      fmt="sashdat"
      fnameWeights=f"{modelName}Weights.{fmt}".lower()
      r = self.s.table.fileInfo(caslib="cora")
      if not fnameWeights in r.FileInfo["Name"].unique():
         newRun = True
      if not os.path.exists(f"../data/{modelName}Best.pkl"):
         newRun = True
      
      if newRun:
         r = self.tuneAnnModel(modelName,tableTrain,featureList,tunerOptions=tunerOptions,tuningParameters=tuningParameters)
         self.saveTables([f"{modelName}Weights"])
         r.BestConfiguration.to_pickle(f"../data/{modelName}Best.pkl")
         r.BestConfiguration.set_index("Name", inplace=True)
         return r.BestConfiguration
      else:
         self.loadTables([f"{modelName}Weights"])
         bestConfiguration = pd.read_pickle(f"../data/{modelName}Best.pkl")
         bestConfiguration.set_index("Name", inplace=True)
         return bestConfiguration
   
   def loadOrTuneForestModel(self, modelName, tableTrain, featureList, tunerOptions=None, newRun=False): 
      coraCaslib="cora"
      self.addCaslibIfNeeded(coraCaslib)

      fmt="sashdat"
      fnameAStore=f"{modelName}AStore.{fmt}"
      r = self.s.table.fileInfo(caslib="cora")
      if not fnameAStore in r.FileInfo["Name"].unique():
         newRun = True
      if not os.path.exists(f"../data/{modelName}Best.pkl"):
         newRun = True
      
      if newRun:
         r = self.tuneForestModel(modelName,tableTrain,featureList,tunerOptions=tunerOptions)
         self.saveTables([f"{modelName}AStore", modelName])
         r.BestConfiguration.to_pickle(f"../data/{modelName}Best.pkl")
         r.BestConfiguration.set_index("Name", inplace=True)
         return r.BestConfiguration
      else:
         self.loadTables([f"{modelName}AStore", modelName])
         bestConfiguration = pd.read_pickle(f"../data/{modelName}Best.pkl")
         bestConfiguration.set_index("Name", inplace=True)
         return bestConfiguration

   def highlightCycle(self, n):
      self.s.datastep.runCode(
         code = f"""
      data linksHighlighted; 
         merge links cycleLinks(in=inCycle where=(cycle={n}));
         by from to;
         length color $8 label $2;
         if inCycle then do;
            color="blue";
            label = put(order+1,2.);
         end;
         else do;
            color = "black";
            label = "";
         end;
      run;
         """
      )
      self.s.datastep.runCode(
         code = f"""
      data nodesHighlighted; 
         merge nodes cycleNodes(in=inCycle where=(cycle={n}));
         length color $8;
         if inCycle then color="blue";
         else color = "black";
      run;
         """
      )
      return graph2dot(linksDf=self.s.CASTable("linksHighlighted"),
            nodesDf=self.s.CASTable("nodesHighlighted"), layout='circo',
            linksColor="color", nodesColor="color", directed=True, stdout=False)
   
   def highlightPath(self, source=None, sink=None):
      if source is None or sink is None:
         pathTable = "pathLinks(in=inPath)"
      else:
         pathTable = f"""pathLinks(in=inPath where=(source="{source}" and sink="{sink}"))"""
      self.s.datastep.runCode(
         code = f"""
      data linksHighlighted; 
         merge links {pathTable};
         by from to;
         length color $8;
         if inPath then color="blue";
         else color = "black";
      run;
         """
      )
      self.s.datastep.runCode(
         code = f"""
      data nodesHighlighted; 
         set {pathTable};
         length color $8;
         if (order EQ 0) then do;
            node = from;
            color="blue";
            output;
         end;
         node = to;
         color="blue";
         output;
         keep node color;
      run;
         """
      )
      return graph2dot(linksDf=self.s.CASTable("linksHighlighted"),
            nodesDf=self.s.CASTable("nodesHighlighted"),
            linksColor="color", nodesColor="color", stdout=False)

   def calculateBetweennessImportance(self, modelName, casOut="featureImportances"):
      self.s.datastep.runCode(
         code = f"""
               data links;
                  _TreeID_= 0;
                  set {modelName};
                  from   = CATS(_TreeID_,'_',_Parent_);
                  to = CATS(_TreeID_,'_',_NodeID_);
                  if _Parent_ NE -1 then output;
                  keep from to;
               run;
         """
      )
      self.s.datastep.runCode(
         code = f"""
               data nodes;
                  _TreeID_= 0;
                  set {modelName};
                  node = CATS(_TreeID_,'_',_NodeID_);
                  type = _NodeName_;
                  keep node type;
               run;
         """
      );
      self.s.network.centrality(
         links="links",
         nodes="nodes",
         outNodes={"name":"outNodes", "replace":True},
         nodesVar={"vars":("type")},
         between="unweight"
      );
      self.s.aggregation.aggregate(
         table={"name":"outNodes","groupby":{"type"},"where":"type ne 'target'"},
         varSpecs=[{"name":"centr_between_unwt", "summarySubset":["SUM"]}],
         casOut={"name":casOut,"replace":True}
      );
      
      self.s.datastep.runCode(
         code = f"""
            data {casOut}; 
               set {casOut}(rename=(type=Variable _centr_between_unwt_Summary_Sum_=betweenImportance));
               drop type_f;
            run;
         """
      )
   
   def loadTree(self, modelName, tableTrain, tree=None):
      maxLevel=int(self.s.CASTable(modelName).max()["_TreeLevel_"]+1)
      modelDf=self.s.CASTable(modelName)[[
         '_NodeID_', '_TreeLevel_', '_NodeName_', '_Parent_',
         '_ParentName_', '_Gain_', '_NumObs_', '_NumDistObs_',
         '_TargetValue_', '_NumChild_', '_ChildID0_', '_ChildID1_',
         '_PBranches_', '_PBLower0_', '_PBUpper0_', '_TreeID_']]
      if tree is None:
         treeDf=modelDf
      else:
         mask = modelDf["_TreeId_"].isin([tree]) 
         treeDf=modelDf[mask]
      treeDf=pd.DataFrame(treeDf.values,
                           columns=treeDf.columns
                           )
      trainDf=self.s.CASTable(tableTrain)
      trainDf=pd.DataFrame(trainDf.values,
                           columns=trainDf.columns
                           )
      for level in range(maxLevel):
         trainDf[f"node{level}"]=np.nan;
      level=0
      levelMask=treeDf["_TreeLevel_"]==level
      for idx,row in islice(treeDf[levelMask].iterrows(), 1):
         trainDf[f"node{level}"] = row["_NodeID_"]
      for level in range(1,maxLevel):
         levelMask=treeDf["_TreeLevel_"]==level
         for idx,row in treeDf[levelMask].iterrows():
               parentMask=(trainDf[f"node{level-1}"] == row["_Parent_"])
               feat=row["_ParentName_"]
               child1Mask=parentMask & (trainDf[feat] >= row["_PBLower0_"]) & (trainDf[feat] <= row["_PBUpper0_"])
               trainDf.loc[child1Mask, f"node{level}"] = row["_NodeID_"]
      treeDf.set_index("_NodeID_", inplace=True)
      return (trainDf, treeDf)
   
   def drawTree(self, trainDf, treeDf, popMasks=dict(), splitMasks=dict(), classMasks=None, classes=[0, 1], showPct=False, showEntropy=False, showGini=False, showNodeImp=False):
      floatCols = ['_PBLower0_', '_PBUpper0_']
      cols = ['PBLower', 'PBUpper']
      treeDf[cols] = treeDf[floatCols].applymap(lambda x: '{0:.2f}'.format(x))
      treeDf["linkLabel"]=treeDf["PBLower"].astype('str').str.cat(treeDf["PBUpper"].astype('str'), sep=",")
      treeDf["nodeLabel"]=treeDf["_NodeName_"]
      for i, row in treeDf.iterrows():
         if i < 0:
            continue
         parent=treeDf.loc[i, "_Parent_"]
         if parent >= 0:
            sibling=treeDf.loc[parent, "_ChildID1_"]
            if sibling==i:
                  sibling=treeDf.loc[parent, "_ChildID0_"]
            isLeft = treeDf.loc[i,"_PBUpper0_"]==treeDf.loc[sibling,"_PBLower0_"]
            if isLeft:
                  treeDf.loc[i,"linkLabel"] = f"[{treeDf.loc[i,'linkLabel']})"
            else:
                  treeDf.loc[i,"linkLabel"] = f"[{treeDf.loc[i,'linkLabel']}]"
            if treeDf.loc[i, "nodeLabel"] == "target":
                  treeDf.loc[i,"nodeLabel"] = f"{treeDf.loc[i,'_TargetValue_'].strip()}"
         if showPct or showEntropy or showGini:
            pMask = popMask(trainDf, treeDf, i, popMasks, splitMasks)
            if classMasks is None:
               classMasks=[]
               for cl in classes:
                  classMasks=classMasks + [trainDf.target == cl]
            targetPct = 100.0*sum(pMask & classMasks[1])/sum(pMask)
            if showPct:
                  treeDf.loc[i,"nodeLabel"] = f"{treeDf.loc[i,'nodeLabel']}\n{'%.2f' % targetPct}%"
            if showEntropy:
                  entr = entropy(trainDf, pMask, classMasks)
                  treeDf.loc[i,"nodeLabel"] = f"{treeDf.loc[i,'nodeLabel']}\n{'%.2f' % entr}"
            if showGini:
                  gini_ = gini(trainDf, pMask, classMasks)
                  treeDf.loc[i,"nodeLabel"] = f"{treeDf.loc[i,'nodeLabel']}\n{'%.2f' % gini_}"
         if showNodeImp:
            treeDf.loc[i,"nodeLabel"] = f"{treeDf.loc[i,'nodeLabel']}\n{'%.2f' % treeDf.loc[i,'contribution']}"
            
      return graph2dot(linksDf=treeDf[treeDf["_Parent_"] > -1],
                        linksFrom="_Parent_", linksTo=None,
                        nodesDf=treeDf,
                        nodesNode=None,
                        nodesLabel="nodeLabel",
                        linksLabel="linkLabel",
                        directed=True, stdout=False, size=45)

   def leafBasedImportances(self, modelName, tableTrain, featureList, classes):
      importances = resetImportances(featureList)
      nTree=int(self.s.CASTable(modelName).max()["_TreeID_"]+1) if "_TreeID_" in self.s.CASTable(modelName).columns else 1
      for tree in [None] if nTree in [None, 1] else range(nTree):
         if tree is not None:
            print(f"tree {tree+1} of {nTree}")
         trainDf, treeDf = self.loadTree(modelName, tableTrain, tree)
         resetContribution(treeDf)
         treeDf["numObs"]=np.nan
         popMasks = resetMasks()
         splitMasks = resetMasks()
         dMasks = resetMasks()
         dLeaves = resetMasks()
         for i in treeDf.index.values:
            treeDf.loc[i, "numObs"] = len(trainDf[popMask(trainDf, treeDf, i, popMasks, splitMasks)])
         nonLeaves = nonLeafNodes(treeDf)
         classMasks=[]
         for cl in classes:
            classMasks=classMasks + [trainDf.target == cl]
         for src in nonLeaves:
            addContribution4(trainDf, treeDf, src, popMasks, splitMasks, dMasks, dLeaves, classMasks)
         addTreeImportance(treeDf, importances)
      return importances
   





def popMask(trainDf, treeDf, i, popMasks, splitMasks):
    if i in popMasks:
        return popMasks[i]
    parentId = treeDf.loc[i,"_Parent_"]
    if parentId < 0:
        mask = (trainDf["node0"] == i) | True
    else:
        mask = splitMask(trainDf, treeDf, i, splitMasks) & popMask(trainDf, treeDf, parentId, popMasks, splitMasks)
    popMasks[i]=mask
    return mask

def resetMasks():
    masks=dict()
    return masks

def splitMask(trainDf, treeDf, i, splitMasks, isLeft=None):
    if isLeft is None:
        parent=treeDf.loc[i, "_Parent_"]
        sibling=treeDf.loc[parent, "_ChildID1_"]
        if sibling==i:
            sibling=treeDf.loc[parent, "_ChildID0_"]
        isLeft = treeDf.loc[i,"_PBUpper0_"]==treeDf.loc[sibling,"_PBLower0_"]
    if i in splitMasks:
        return splitMasks[i]
    feat=treeDf.loc[i, "_ParentName_"]
    if isLeft:
        mask = (trainDf[feat] >= treeDf.loc[i,"_PBLower0_"]) & (trainDf[feat] < treeDf.loc[i,"_PBUpper0_"])
    else:
        mask = (trainDf[feat] >= treeDf.loc[i,"_PBLower0_"]) & (trainDf[feat] <= treeDf.loc[i,"_PBUpper0_"])
    splitMasks[i]=mask
    return mask

def descendantLeaves(trainDf, treeDf, i, left, dLeaves):
    key = (i,left)
    if key in dLeaves:
        return dLeaves[key]
    childId = treeDf.loc[i, "_ChildID0_"] if left else treeDf.loc[i, "_ChildID1_"]
    if treeDf.loc[childId, "_NumChild_"] == 0:
        return [childId]
    leaves1 = descendantLeaves(trainDf, treeDf, childId, True, dLeaves)
    leaves2 = descendantLeaves(trainDf, treeDf, childId, False, dLeaves)
    dLeaves[key]=leaves1 + leaves2
    return dLeaves[key]

def descendantMasks(trainDf, treeDf, i, splitMasks, left, dMasks, first=True):
    key = (i,left, first)
    if key in dMasks:
        return dMasks[key]
    childId = treeDf.loc[i, "_ChildID0_"] if left else treeDf.loc[i, "_ChildID1_"]
    childMask = True if first else splitMask(trainDf, treeDf, childId, splitMasks, left)
    if treeDf.loc[childId, "_NumChild_"] == 0:
        dMasks[key]=[childMask]
        return [childMask]
    
    masks1 = [mask & childMask for mask in descendantMasks(trainDf, treeDf, childId, splitMasks, True, dMasks, False)]
    masks2 = [mask & childMask for mask in descendantMasks(trainDf, treeDf, childId, splitMasks, False, dMasks, False)]
    dMasks[key]=masks1 + masks2
    return dMasks[key]

def onPath(treeDf, i, s, t):
    indA=s
    indB=t
    indC=i
    a = treeDf.loc[indA]
    b = treeDf.loc[indB]
    c = treeDf.loc[indC]
    while (indA != indB):
        if(indA == indC or indB == indC):
            return True
        if(a._TreeLevel_ > b._TreeLevel_):
            indA = a._Parent_
            a = treeDf.loc[indA]
        else:
            indB = b._Parent_
            b = treeDf.loc[indB]
    return False

def gini(trainDf, mask, classMasks):
    ret = 0
    denom = sum(mask)
    if denom==0:
        return 0
    for classMask in classMasks:
        p = sum(mask & classMask) / denom
        ret = ret + p*(1-p)
    return ret

def entropy(trainDf, mask, classMasks):
    ret = 0
    denom = sum(mask)
    if denom==0:
        return 0
    for classMask in classMasks:
        p = sum(mask & classMask) / denom
        if p > 0:
            ret = ret - p*np.log(p)
    return ret

def gamma4(trainDf, treeDf, i, popMasks, splitMasks, dMasks, dLeaves, classMasks, impurityFunc=gini):
    masksL = descendantMasks(trainDf, treeDf, i, splitMasks, True, dMasks)
    masksR = descendantMasks(trainDf, treeDf, i, splitMasks, False, dMasks)
    leavesL = descendantLeaves(trainDf, treeDf, i, True, dLeaves)
    leavesR = descendantLeaves(trainDf, treeDf, i, False, dLeaves)
    maskI = popMask(trainDf, treeDf, i, popMasks, splitMasks)
    numI = sum(maskI)
    if numI == 0:
        return 0
    ret = 0
    for leaf in (leavesL+leavesR):
        leafMask = popMask(trainDf, treeDf, leaf, popMasks, splitMasks)
        ret -= impurityFunc(trainDf, leafMask, classMasks)*sum(leafMask)
   
    for mask in (masksL+masksR):
        leafMask = maskI & mask
        ret += 0.5*impurityFunc(trainDf, leafMask, classMasks)*sum(leafMask)

    return ret

def nodesBetween(treeDf, s, t):
    ret=set()
    indA=s
    indB=t
    a = treeDf.loc[indA]
    b = treeDf.loc[indB]
    while (indA != indB):
        if(a._TreeLevel_ > b._TreeLevel_):
            indA = a._Parent_
            a = treeDf.loc[indA]
            ret.add(indA)
        else:
            indB = b._Parent_
            b = treeDf.loc[indB]
            ret.add(indB)
    return ret


def leafNodes(treeDf):
   return treeDf[treeDf._NumChild_==0].index.values

def nonLeafNodes(treeDf):
   return treeDf[treeDf._NumChild_>0].index.values

def resetContribution(treeDf):
    treeDf["contribution"]=0.0 

def addContribution1(trainDf, treeDf, s, t, maskS, maskT, fraction, classMasks):
    for i in nodesBetween(treeDf, s, t):
        treeDf.loc[i, "contribution"] += gamma1(trainDf, treeDf, i, maskS, maskT, fraction, classMasks)

def addContribution2(trainDf, treeDf, s, t, maskS, maskT, numS, numT, numST, numTrain, classMasks):
    gamma=gamma2(trainDf, treeDf, maskS, maskT, numS, numT, numST, numTrain, classMasks)
    for i in nodesBetween(treeDf, s, t):
        treeDf.loc[i, "contribution"] += gamma

def addContribution3(trainDf, treeDf, s, t, maskT, numTrain, classMasks, popMasks):
    for i in nodesBetween(treeDf, s, t):
        maskI = popMask(trainDf,i,popMasks)
        maskIT = maskI | maskT
        numIT = sum(maskIT)
        gamma=gamma3(trainDf, treeDf, i, maskIT, numIT, numTrain, classMasks)
        treeDf.loc[i, "contribution"] += gamma

def addContribution4(trainDf, treeDf, i, popMasks, splitMasks, dMasks, dLeaves, classMasks):
    numTrain = len(trainDf)
    maskI = popMask(trainDf, treeDf, i, popMasks, splitMasks)
    numI = sum(maskI)
    gamma = gamma4(trainDf, treeDf, i, popMasks, splitMasks, dMasks, dLeaves, classMasks)
    treeDf.loc[i, "contribution"] += gamma*numI/numTrain
    

def resetImportances(featureList):
    importances = dict()
    for feat in featureList:
        importances[feat]=0.0
    return importances
        
def addTreeImportance(treeDf, importances):
    for idx, row in treeDf.iterrows():
        if row._NumChild_ > 0:
            importances[row._NodeName_] += row.contribution

def printImportances(d, n=10):
    d_view = [ (v,k) for k,v in d.items() ]
    d_view.sort(reverse=True)
    i=0
    ret = []
    for v,k in d_view:
        i=i+1
        if i>n:
            break
        print("% 36s: % 12f" % (k,v))
        ret = ret + [k]
    return ret

def graph2dot(linksDf=None, nodesDf=None, linksFrom="from", linksTo="to", nodesNode="node",
              nodesLabel=None,
              nodesSize=None,
              nodesSizeScale=1,
              nodesColor=None,
              linksLabel=None,
              linksColor=None,
              outFile=None,
              view=True,
              stdout=None,
              size=10,
              layout=None,
              directed=False,
              sort=False
             ):
    dot = Digraph() if directed else Graph();
    dot.attr(rankdir='LR')
    dot.attr(size=f"{size}")
    dot.attr('node', shape='circle')
    if layout is not None:
        dot.attr(layout=f"{layout}")
        
    if(linksDf is not None):
        for index, row in (linksDf.sort([linksFrom, linksTo]).iterrows() if sort else linksDf.iterrows()):
            fromVal = str(index) if linksFrom is None else f"{row[linksFrom]}"
            toVal = str(index) if linksTo is None else f"{row[linksTo]}"
            dot.edge(fromVal, toVal,
                     label=None if (linksLabel is None) else f"{row[linksLabel]}",
                     color=None if (linksColor is None) else row[linksColor]
                    )
    
    if(nodesDf is not None):
        for index, row in (nodesDf.sort([nodesNode]).iterrows() if sort else nodesDf.iterrows()):
            nodeVal = str(index) if nodesNode is None else f"{row[nodesNode]}"
            dot.node(nodeVal, nodeVal if nodesLabel is None else f"{row[nodesLabel]}",
                     width=None if (nodesSize is None) else f"{1*nodesSizeScale*row[nodesSize]}",
                     color=None if (linksColor is None) else row[linksColor]
                    )
    if stdout is None:
        stdout = True if outFile is None else False
    if stdout:
        print(dot.source)
    if outFile is not None:
        dot.render(f"../dot/{outFile}", view=view)
    return dot

def showReachNeighborhood(session,
                          tableLinks,
                          tableNodes,
                          node,
                          hops,
                          directed=False,
                          size=5,
                          layout="fdp",
                          nodesSizeScale=100
                         ):
   nodeSub = {
    "node": [node],
    "reach":[1]
   } 
   nodeSubDf = pd.DataFrame(nodeSub, columns = ["node", "reach"])
   session.upload(nodeSubDf, casout={"name": "_nodeSub_", "replace": True});
   session.network.reach(
      loglevel = "NONE",
      direction = "directed" if directed else "undirected",
      links = tableLinks,
      nodes = tableNodes,
      nodesVar = {"vars":["target"]},
      maxReach = hops,
      outReachLinks = {"name":"_reachLinks_", "replace":True},
      outReachNodes = {"name":"_reachNodes_", "replace":True},
      nodesSubset = "_nodeSub_"   
   )
   session.datastep.runCode(
      code = f"""
         data _reachNodes_; 
            set _reachNodes_;
            length label $50;
            label=target || "\nPaperId = " || put(node, 7.);
            if put(node, 7.) = {node} then label = "???" || "\nPaperId = " || put(node, 7.);
         run;
      """
    )
   return graph2dot(linksDf=session.CASTable("_reachLinks_"),
                    nodesDf=session.CASTable("_reachNodes_"),
                    nodesLabel="label",
                    layout=layout,
                    directed=directed,
                    size=size,
                    nodesSizeScale=nodesSizeScale,
                    stdout=False)