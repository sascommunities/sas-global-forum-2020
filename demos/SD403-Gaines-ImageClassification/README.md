# Image Classification Using SAS&reg;
Learn how to develop SAS&reg; code for training a deep learning model for image classification. The demo shows how the new Load Images task (in SAS&reg; Viya&reg; 3.5 / SAS&reg; Studio 5.2) can jump-start the code development for training an image classifier using SAS code.  The example covers the end-to-end process, from loading your images to creating an analytic model store that you can use to put the model into production.

## Prerequisites
To use the following materials, you need access to a SAS&reg; Cloud Analytic Services (CAS) server that has a license for [SAS&reg; Visual Data Mining & Machine Learning](https://www.sas.com/en_us/software/visual-data-mining-machine-learning.html).  For more information on free software trials of SAS Viya, visit the [SAS Trials website](https://www.sas.com/en_us/trials.html).

After you have access to SAS Visual Data Mining & Machine Learning, you need to download the example image data set in addition to a ZIP file that contains the pre-trained ResNet-50 weights and the labels for the ImageNet data set.  

### Example data
1. Download the example image data set that contains dolphins and giraffes from the [SAS Studio support website](https://support.sas.com/en/software/studio-support.html). It is the "Load Image Example (ZIP)" link in the Documentation section ([direct link to data set](http://support.sas.com/documentation/onlinedoc/sasstudio/5.2/giraffe_dolphin_small.zip)).
	* This data set is a subset of the "[animals with attributes 2](https://cvml.ist.ac.at/AwA2/)" data set from Xian et al. (2018).
2. Unzip the ``giraffe_dolphin_small.zip`` file to a directory that is accessible to SAS Studio and to your CAS server.  
3. In the ``imageClassification.sas`` file, use the file path to this directory for the ``imagePath`` macro variable.  

### Pre-trained weights
1. Download the pre-trained weights and other supporting files for the ResNet-50 model from the [SAS Deep Learning Models and Tools](https://support.sas.com/documentation/prod-p/vdmml/zip/index.html) website ([direct link to ZIP file](https://support.sas.com/documentation/prod-p/vdmml/zip/resnet50.zip)).   
    * This website also contains model files for other popular deep learning models.  
2. Unzip the ``resnet50.zip`` file to a directory that is accessible to SAS Studio and to your CAS server.  
3. In the ``imageClassification.sas`` file, use the file path to this directory for the ``modelPath`` macro variable. This also applies to ``imageClassificationLoadedTable.sas``.


## Files
* imageClassification.sas
	* This is the main code file that covers the end-to-end image classification example.  
	* At a minimum, you must specify values for the ``imagePath`` and ``modelPath`` macro variables.
		* ``imagePath``:  This is the file path to the directory where you unzipped the ``giraffe_dolphin_small.zip`` file (see the ``Example data`` section).
		* ``modelPath``:  This is the file path to the directory where you unzipped the ``resnet50.zip`` file (see the ``Pre-trained weights`` section).
 
* imageClassificationLoadedTable.sas
    * This is an alternative version of the code to use if your images are already in an in-memory table, which you can accomplish with the [Load Images](https://go.documentation.sas.com/?activeCdc=webeditorcdc&cdcId=sasstudiocdc&cdcVersion=5.2&docsetId=webeditorref&docsetTarget=p0xc55tobpulbrn1tynh6fe9w9c9.htm&locale=en) task.  This code continues the analytics life cycle in the exploration phase and continues through the creation of an analytic store that you can use to put the model into production.          
    
* imageClassification-resultResNet50.html
    * Results from scoring the validation data set with the fine-tuned ResNet-50 model.
    
* imageClassification-resultSimpleCNN.html 
    * Results from scoring the validation data set with the Simple CNN model.  
    
* model_resnet50_sgf.sas
    * Code file to build the ResNet-50 model architecture. It is a modified version of the ``model_resnet50.sas`` file available in the [model utilities ZIP file](https://support.sas.com/documentation/prod-p/vdmml/zip/models.zip) from the [SAS Deep Learning Models and Tools](https://support.sas.com/documentation/prod-p/vdmml/zip/index.html) website.
 

## Additional information
The inspiration for this demo came from a [SAS DLPy image classification example](https://github.com/sassoftware/python-dlpy/blob/master/examples/quick_start/A_Comprehensive_Image_Classification_Example.ipynb).  [DLPy](https://github.com/sassoftware/python-dlpy) is a high-level Python library for the [SAS Deep Learning](https://go.documentation.sas.com/?docsetId=casdlpg&docsetTarget=n0gv3jjm5obouun1uvducbzl8nlf.htm&docsetVersion=8.2&locale=en) features.

After my super demo is recorded and uploaded to YouTube, I will add a link to the video.  


## Support contact
Your questions and comments are valued and encouraged.  Connect with the author, Brian R. Gaines: [email](mailto:Brian.Gaines@sas.com), [personal website](http://brgaines.github.io/), [Twitter](https://twitter.com/brgainesStats), or [LinkedIn](http://linkedin.com/in/BrianGainesStats).   

## References
Xian, Y., Lampert, C. H., Schiele, B., and Akata, Z. (2018).  "[Zero-Shot Learning - A Comprehensive Evaluation of the Good, the Bad and the Ugly](https://doi.org/10.1109/TPAMI.2018.2857768)", *IEEE Transactions on Pattern Analysis and Machine Intelligence (T-PAMI)* 40(8). ([arXiv:1707.00600 [cs.CV]](https://arxiv.org/abs/1707.00600)) 