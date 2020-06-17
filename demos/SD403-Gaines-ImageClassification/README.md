# Image Classification Using SAS&reg;
Learn how to develop SAS&reg; code for training a deep learning model for image classification. The demo shows how the new Load Images task (in SAS&reg; Viya&reg; 3.5 / SAS&reg; Studio 5.2) can jump-start the code development for training an image classifier using SAS code.  The example covers the end-to-end process, from loading your images to creating an analytic model store that you can use to put the model into production.



## Prerequisites
To use the following materials, you need access to a SAS&reg; Cloud Analytic Services (CAS) server that has a license for [SAS&reg; Visual Data Mining & Machine Learning](https://www.sas.com/en_us/software/visual-data-mining-machine-learning.html).  For more information on free software trials of SAS Viya, visit the [SAS Trials website](https://www.sas.com/en_us/trials.html).

After you have access to SAS Visual Data Mining & Machine Learning, you need to download the example image data set in addition to a ZIP file that contains the pretrained ResNet-50 weights and the labels for the ImageNet data set.  

### Example data
1. Download the example image data set that contains dolphins and giraffes from the [SAS Studio support website](https://support.sas.com/en/software/studio-support.html). It is the "Load Image Example (ZIP)" link in the Documentation section ([direct link to data set](http://support.sas.com/documentation/onlinedoc/sasstudio/5.2/giraffe_dolphin_small.zip)).
	* This data set is a subset of the "[animals with attributes 2](https://cvml.ist.ac.at/AwA2/)" data set from Xian et al. (2018).
2. Unzip the ``giraffe_dolphin_small.zip`` file to a directory that is accessible to SAS Studio and to your CAS server.  
3. In the ``imageClassification.sas`` file, use the file path to this directory for the ``imagePath`` macro variable.  

### Pretrained weights and model file
1. Download the pretrained weights and other supporting files for the ResNet-50 model from the [SAS Deep Learning Models and Tools](https://support.sas.com/documentation/prod-p/vdmml/zip/index.html) website ([direct link to ZIP file](https://support.sas.com/documentation/prod-p/vdmml/zip/resnet50.zip)).   
    * This website also contains model files for other popular deep learning models.  
2. Unzip the ``resnet50.zip`` file to a directory that is accessible to SAS Studio and to your CAS server.  
3. Place the ``model_resnet50_sgf.sas`` model architecture file in this same directory.
4. In the ``imageClassification.sas`` file, use the file path to this directory for the ``modelPath`` macro variable. This also applies to ``imageClassificationLoadedTable.sas``.


## Files
* imageClassification.sas
	* This is the main code file that covers the end-to-end image classification example.  
	* At a minimum, you must specify values for the ``imagePath`` and ``modelPath`` macro variables.
		* ``imagePath``:  This is the file path to the directory where you unzipped the ``giraffe_dolphin_small.zip`` file (see the ``Example data`` section).
		* ``modelPath``:  This is the file path to the directory where you placed the contents of the ``resnet50.zip`` file and ``model_resnet50_sgf.sas`` (see the ``Pretrained weights and model file`` section).
 
* imageClassificationLoadedTable.sas
    * This is an alternative version of the code to use if your images are already in an in-memory table, which you can accomplish with the [Load Images](https://go.documentation.sas.com/?activeCdc=webeditorcdc&cdcId=sasstudiocdc&cdcVersion=5.2&docsetId=webeditorref&docsetTarget=p0xc55tobpulbrn1tynh6fe9w9c9.htm&locale=en) task.  This code continues the analytics life cycle in the exploration phase and continues through the creation of an analytic store that you can use to put the model into production.          
    
* imageClassification-resultResNet50.html
    * Results from scoring the validation data set with the fine-tuned ResNet-50 model.
    
* imageClassification-resultSimpleCNN.html 
    * Results from scoring the validation data set with the Simple CNN model.  
    
* model_resnet50_sgf.sas
    * Code file to build the ResNet-50 model architecture. It is a modified version of the ``model_resnet50.sas`` file available in the [model utilities ZIP file](https://support.sas.com/documentation/prod-p/vdmml/zip/models.zip) from the [SAS Deep Learning Models and Tools](https://support.sas.com/documentation/prod-p/vdmml/zip/index.html) website.
    * Place this file in the directory that corresponds to the ``modelPath`` macro variable.  
 

## Additional information
The inspiration for this demo came from a [SAS DLPy image classification example](https://github.com/sassoftware/python-dlpy/blob/master/examples/quick_start/A_Comprehensive_Image_Classification_Example.ipynb).  [DLPy](https://github.com/sassoftware/python-dlpy) is a high-level Python library for the [SAS Deep Learning](https://go.documentation.sas.com/?docsetId=casdlpg&docsetTarget=titlepage.htm&docsetVersion=8.5&locale=en) features.  

After my super demo is recorded and uploaded to YouTube, I will add a link to the video.  

## Additional resources
The following resources provide further information about deep learning from SAS:  

* [Deep Learning for Computer Vision with SAS: An Introduction](https://www.sas.com/store/books/categories/usage-and-reference/deep-learning-for-computer-vision-with-sas-an-introduction/prodBK_73903_en.html)
* [Getting Started with Deep Learning Using the SAS Language](https://blogs.sas.com/content/subconsciousmusings/2020/04/06/getting-started-with-deep-learning-using-the-sas-language/)
* [Getting Started with Deep Learning YouTube Playlist](https://www.youtube.com/watch?v=0qm_OL_VHGE&list=PLVV6eZFA22QyaxYBynL-1Btk-nIMKmOqY&index=8) 
* [How to Build Deep Learning Models with SAS](https://blogs.sas.com/content/subconsciousmusings/2018/04/20/how-to-build-deep-learning-models-with-sas/)
* [How to Do Deep Learning with SAS](https://www.sas.com/en_us/whitepapers/deep-learning-with-sas-109610.html)
* [SAS DLPy examples](https://github.com/sassoftware/python-dlpy/tree/master/examples)
* [SAS Studio Task Reference Guide](https://go.documentation.sas.com/?activeCdc=webeditorcdc&cdcId=sasstudiocdc&cdcVersion=5.2&docsetId=webeditorref&docsetTarget=p0wc36sf6dy5zyn112v83e5rl5y1.htm&locale=en)
* [SAS Visual Data Mining and Machine Learning 8.5: Deep Learning Programming Guide](https://go.documentation.sas.com/?docsetId=casdlpg&docsetTarget=n0ep2b9u60m7uzn173wx9v9t7dxp.htm&docsetVersion=8.5&locale=en)


The following is a list of deep learning papers and presentations from SAS Global Forum 2020:

* Bringing Computer Vision to the Edge: An Overview of Real-Time Image Analytics with SAS
    * [Paper](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2020/4432-2020.pdf)
    * [Presentation](https://www.youtube.com/watch?v=USK2tbAF1zw&list=PLVV6eZFA22Qzg3FIBHuHqY924ZvLjh6Zc&index=17&t=0s)
* Deploying Computer Vision by Combining Deep Learning Action Sets with Open Source Technology
    * [Paper](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2020/4694-2020.pdf)
    * [Presentation](https://www.youtube.com/watch?v=8IOFuqLcbio)
* [Face Recognition using SAS Viya: Guess who the person is!](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2020/5039-2020.pdf) (poster)
* [How We Monitor Bee Activity at the SAS Bee Hives using IoT and Computer Vision](https://www.youtube.com/watch?v=4k4JkladnEc) (presentation)
* [Medical Image Analyses in SAS® Viya® with Applications in Automatic Tissue Morphometry in the Clinic](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2020/4491-2020.pdf) (paper)
* [Multilingual Sentiment Analysis: An RNN-Based Framework for Limited Data](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2020/4180-2020.pdf) (paper)
* [NLP with BERT: Sentiment Analysis Using SAS® Deep Learning and DLPy](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2020/4429-2020.pdf) (paper)
* [SAS Visual Defect Detection System](https://www.youtube.com/watch?v=T2nLT2TWggg) (presentation)
* [Transfer Learning for Mining Digital Phenotype by SAS Viya](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2020/5029-2020.pdf) (paper)



## Support contact
Your questions and comments are valued and encouraged.  Connect with the author, Brian R. Gaines: [email](mailto:Brian.Gaines@sas.com), [personal website](http://brgaines.github.io/), [Twitter](https://twitter.com/brgainesStats), or [LinkedIn](http://linkedin.com/in/BrianGainesStats).   

## References
Xian, Y., Lampert, C. H., Schiele, B., and Akata, Z. (2018).  "[Zero-Shot Learning - A Comprehensive Evaluation of the Good, the Bad and the Ugly](https://doi.org/10.1109/TPAMI.2018.2857768)", *IEEE Transactions on Pattern Analysis and Machine Intelligence (T-PAMI)* 40(8). ([arXiv:1707.00600 [cs.CV]](https://arxiv.org/abs/1707.00600)) 