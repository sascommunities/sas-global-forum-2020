/********************************************************************************/
/*                Code for SAS Global Forum 2020 Super Demo SD403               */
/*                    Title: Image Classification Using SAS®                    */
/*                           Author: Brian R. Gaines                            */
/*                                                                              */
/* Description:                                                                 */
/*    This code defines the ResNet-50 model architecture.  It creates an        */
/*    in-memory model table in the active caslib named ResNet50. It uses the    */
/*    channel means for the offsets in the input layer.                         */
/*                                                                              */
/* Notes                                                                        */
/*    See the directory for this super demo in the SASGF 2020 GitHub repository */
/*    for more information, including an example that uses this code.  Please   */
/*    feel free to contact the author if you have questions or issues.          */
/*                                                                              */
/* Source                                                                       */
/*    This is a modified version of model_resnet50.sas available in models.zip  */
/*    https://support.sas.com/documentation/prod-p/vdmml/zip/index.html         */
/********************************************************************************/


    /* Create empty ResNet50 model in the active caslib */
    action deepLearn.buildModel / model={name='ResNet50', replace=1} type = "CNN";

    /* -------------------- Input layer ---------------------- */

    /* Calculate and save channel means */
    action image.summarizeImages result=summary / 
                table={caslib="&imageTrainingCaslibName", name="&imageTrainingTableName"};
    _inputOffsets_=summary.Summary[1, {"mean1stChannel","mean2ndChannel", "mean3rdChannel"}];

    /* Add input layer (use channel means for offsets) */
    action deepLearn.addLayer / model="ResNet50" name="data"
               layer={type='input' nchannels=3, width=224, height=224, offsets=_inputOffsets_};

    /* -------------------- Layer 1 ---------------------- */
    
    /* conv1 layer: 64 channels, 7x7 conv, stride=2; output = 112 x 112 */
    AddLayer/model='ResNet50' name="conv1" 
            layer={type='convolution' nFilters=64 width=7 height=7 stride=2 act="IDENTITY"} srcLayers={"data"};
    run;
 
    /* conv1 batch norm layer: 64 channels, output = 112 x 112 */
    AddLayer/model='ResNet50' name="bn_conv1"
            layer={type='batchnorm' act='RELU'} srcLayers={"conv1"};
    run;

    /* pool1 layer: 64 channels, 3x3 pooling, output = 56 x 56 */
    AddLayer/model='ResNet50' name="pool1" 
            layer={type='pooling' width=3 height=3 stride=2 pool='max'} srcLayers={"bn_conv1"};
    run;

    /* ------------------- Residual Layer 2A ----------------------- */
    
    /* res2a_branch1 layer: 256 channels, 1x1 conv, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2a_branch1" 
            layer={type='convolution' nFilters=256 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"pool1"};
    run;

    /* res2a_branch1 batch norm layer: 256 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="bn2a_branch1"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res2a_branch1"};
    run;

    /* res2a_branch2a layer: 64 channels, 1x1 conv, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2a_branch2a" 
            layer={type='convolution' nFilters=64 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"pool1"};
    run;

    /* res2a_branch2a batch norm layer: 64 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="bn2a_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res2a_branch2a"};
    run;
    
    /* res2a_branch2b layer: 64 channels, 3x3 conv, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2a_branch2b" 
            layer={type='convolution' nFilters=64 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn2a_branch2a"};
    run;

    /* res2a_branch2b batch norm layer: 64 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="bn2a_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res2a_branch2b"};
    run;

    /* res2a_branch2c layer: 256 channels, 1x1 conv, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2a_branch2c" 
            layer={type='convolution' nFilters=256 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn2a_branch2b"};
    run;

    /* res2a_branch2c batch norm layer: 256 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="bn2a_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res2a_branch2c"};
    run;
    
    /* res2a residual layer: 256 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2a"
            layer={type='residual' act='RELU'} srcLayers={"bn2a_branch2c","bn2a_branch1"};
    run;
    
    /* ------------------- Residual Layer 2B ----------------------- */
    
    /* res2b_branch2a convolution layer: 64 channels, 1x1 conv, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2b_branch2a" 
            layer={type='convolution' nFilters=64 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res2a"};
    run;

    /* res2b_branch2a batch norm layer: 64 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="bn2b_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res2b_branch2a"};
    run;

    /* res2b_branch2b convolution layer: 64 channels, 3x3 conv, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2b_branch2b" 
            layer={type='convolution' nFilters=64 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn2b_branch2a"};
    run;

    /* res2b_branch2b batch norm layer: 64 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="bn2b_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res2b_branch2b"};
    run;
    
    /* res2b_branch2c layer: 256 channels, 1x1 conv, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2b_branch2c" 
            layer={type='convolution' nFilters=256 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn2b_branch2b"};
    run;

    /* res2b_branch2c batch norm layer: 256 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="bn2b_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res2b_branch2c"};
    run;
    
    /* res2b residual layer: 256 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2b"
            layer={type='residual' act='RELU'} srcLayers={"res2a","bn2b_branch2c"};
    run;

    /* ------------------- Residual Layer 2C ----------------------- */
    
    /* res2c_branch2a convolution layer: 64 channels, 1x1 conv, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2c_branch2a" 
            layer={type='convolution' nFilters=64 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res2b"};
    run;

    /* res2c_branch2a batch norm layer: 64 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="bn2c_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res2c_branch2a"};
    run;

    /* res2c_branch2b convolution layer: 64 channels, 3x3 conv, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2c_branch2b" 
            layer={type='convolution' nFilters=64 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn2c_branch2a"};
    run;

    /* res2c_branch2b batch norm layer: 64 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="bn2c_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res2c_branch2b"};
    run;
    
    /* res2c_branch2c layer: 256 channels, 1x1 conv, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2c_branch2c" 
            layer={type='convolution' nFilters=256 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn2c_branch2b"};
    run;

    /* res2c_branch2c batch norm layer: 256 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="bn2c_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res2c_branch2c"};
    run;
    
    /* res2c residual layer: 256 channels, output = 56 x 56 */
    AddLayer/model='ResNet50' name="res2c"
            layer={type='residual' act='RELU'} srcLayers={"res2b","bn2c_branch2c"};
    run;
    
    /* ------------- Layer 3A -------------------- */
    
    /* res3a_branch1 layer: 512 channels, 1x1 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3a_branch1" 
            layer={type='convolution' nFilters=512 width=1 height=1 stride=2 noBias=TRUE act="IDENTITY"} srcLayers={"res2c"};
    run;

    /* res3a_branch1 batch norm layer: 512 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3a_branch1"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res3a_branch1"};
    run;

    /* res3a_branch2a layer: 128 channels, 1x1 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3a_branch2a" 
            layer={type='convolution' nFilters=128 width=1 height=1 stride=2 noBias=TRUE act="IDENTITY"} srcLayers={"res2c"};
    run;

    /* res3a_branch2a batch norm layer: 128 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3a_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res3a_branch2a"};
    run;

    /* res3a_branch2b layer: 128 channels, 3x3 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3a_branch2b" 
            layer={type='convolution' nFilters=128 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn3a_branch2a"};
    run;

    /* res3a_branch2b batch norm layer: 128 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3a_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res3a_branch2b"};
    run;

    /* res3a_branch2c layer: 512 channels, 1x1 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3a_branch2c" 
            layer={type='convolution' nFilters=512 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn3a_branch2b"};
    run;

    /* res3a_branch2c batch norm layer: 512 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3a_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res3a_branch2c"};
    run;
    
    /* res3a residual layer: 512 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3a"
            layer={type='residual' act='RELU'} srcLayers={"bn3a_branch2c","bn3a_branch1"};
    run;
    
    /* ------------------- Residual Layer 3B ----------------------- */
    
    /* res3b_branch2a convolution layer: 128 channels, 1x1 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3b_branch2a" 
            layer={type='convolution' nFilters=128 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res3a"};
    run;

    /* res3b_branch2a batch norm layer: 128 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3b_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res3b_branch2a"};
    run;

    /* res3b_branch2b convolution layer: 128 channels, 3x3 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3b_branch2b" 
            layer={type='convolution' nFilters=128 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn3b_branch2a"};
    run;

    /* res3b_branch2b batch norm layer: 128 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3b_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res3b_branch2b"};
    run;
    
    /* res3b_branch2c layer: 512 channels, 1x1 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3b_branch2c" 
            layer={type='convolution' nFilters=512 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn3b_branch2b"};
    run;

    /* res3b_branch2c batch norm layer: 512 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3b_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res3b_branch2c"};
    run;
    
    /* res3b residual layer: 512 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3b"
            layer={type='residual' act='RELU'} srcLayers={"res3a","bn3b_branch2c"};
    run;
    
    /* ------------------- Residual Layer 3C ----------------------- */
    
    /* res3c_branch2a convolution layer: 128 channels, 1x1 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3c_branch2a" 
            layer={type='convolution' nFilters=128 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res3b"};
    run;

    /* res3c_branch2a batch norm layer: 128 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3c_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res3c_branch2a"};
    run;

    /* res3c_branch2b convolution layer: 128 channels, 3x3 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3c_branch2b" 
            layer={type='convolution' nFilters=128 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn3c_branch2a"};
    run;

    /* res3c_branch2b batch norm layer: 128 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3c_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res3c_branch2b"};
    run;
    
    /* res3c_branch2c layer: 512 channels, 1x1 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3c_branch2c" 
            layer={type='convolution' nFilters=512 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn3c_branch2b"};
    run;

    /* res3c_branch2c batch norm layer: 512 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3c_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res3c_branch2c"};
    run;
    
    /* res3c residual layer: 512 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3c"
            layer={type='residual' act='RELU'} srcLayers={"res3b","bn3c_branch2c"};
    run;
    
    /* ------------------- Residual Layer 3D ----------------------- */
    
    /* res3d_branch2a convolution layer: 128 channels, 1x1 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3d_branch2a" 
            layer={type='convolution' nFilters=128 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res3c"};
    run;

    /* res3d_branch2a batch norm layer: 128 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3d_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res3d_branch2a"};
    run;

    /* res3d_branch2b convolution layer: 128 channels, 3x3 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3d_branch2b" 
            layer={type='convolution' nFilters=128 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn3d_branch2a"};
    run;

    /* res3d_branch2b batch norm layer: 128 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3d_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res3d_branch2b"};
    run;
    
    /* res3d_branch2c layer: 512 channels, 1x1 conv, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3d_branch2c" 
            layer={type='convolution' nFilters=512 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn3d_branch2b"};
    run;

    /* res3d_branch2c batch norm layer: 512 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="bn3d_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res3d_branch2c"};
    run;
    
    /* res3d residual layer: 512 channels, output = 28 x 28 */
    AddLayer/model='ResNet50' name="res3d"
            layer={type='residual' act='RELU'} srcLayers={"res3c","bn3d_branch2c"};
    run;
    
    /* ------------- Layer 4A -------------------- */
    
    /* res4a_branch1 layer: 1024 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4a_branch1" 
            layer={type='convolution' nFilters=1024 width=1 height=1 stride=2 noBias=TRUE act="IDENTITY"} srcLayers={"res3d"};
    run;

    /* res4a_branch1 batch norm layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4a_branch1"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res4a_branch1"};
    run;

    /* res4a_branch2a layer: 256 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4a_branch2a" 
            layer={type='convolution' nFilters=256 width=1 height=1 stride=2 noBias=TRUE act="IDENTITY"} srcLayers={"res3d"};
    run;

    /* res4a_branch2a batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4a_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4a_branch2a"};
    run;

    /* res4a_branch2b layer: 256 channels, 3x3 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4a_branch2b" 
            layer={type='convolution' nFilters=256 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4a_branch2a"};
    run;

    /* res4a_branch2b batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4a_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4a_branch2b"};
    run;

    /* res4a_branch2c layer: 1024 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4a_branch2c" 
            layer={type='convolution' nFilters=1024 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4a_branch2b"};
    run;

    /* res4a_branch2c batch norm layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4a_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res4a_branch2c"};
    run;
    
    /* res4a residual layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4a"
            layer={type='residual' act='RELU'} srcLayers={"bn4a_branch2c","bn4a_branch1"};
    run;
    
    /* ------------------- Residual Layer 4B ----------------------- */
    
    /* res4b_branch2a convolution layer: 256 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4b_branch2a" 
            layer={type='convolution' nFilters=256 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res4a"};
    run;

    /* res4b_branch2a batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4b_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4b_branch2a"};
    run;

    /* res4b_branch2b convolution layer: 256 channels, 3x3 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4b_branch2b" 
            layer={type='convolution' nFilters=256 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4b_branch2a"};
    run;

    /* res4b_branch2b batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4b_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4b_branch2b"};
    run;
    
    /* res4b_branch2c layer: 1024 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4b_branch2c" 
            layer={type='convolution' nFilters=1024 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4b_branch2b"};
    run;

    /* res4b_branch2c batch norm layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4b_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res4b_branch2c"};
    run;
    
    /* res4b residual layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4b"
            layer={type='residual' act='RELU'} srcLayers={"res4a","bn4b_branch2c"};
    run;
    
    /* ------------------- Residual Layer 4C ----------------------- */
    
    /* res4c_branch2a convolution layer: 256 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4c_branch2a" 
            layer={type='convolution' nFilters=256 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res4b"};
    run;

    /* res4c_branch2a batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4c_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4c_branch2a"};
    run;

    /* res4c_branch2b convolution layer: 256 channels, 3x3 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4c_branch2b" 
            layer={type='convolution' nFilters=256 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4c_branch2a"};
    run;

    /* res4c_branch2b batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4c_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4c_branch2b"};
    run;
    
    /* res4c_branch2c layer: 1024 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4c_branch2c" 
            layer={type='convolution' nFilters=1024 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4c_branch2b"};
    run;

    /* res4c_branch2c batch norm layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4c_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res4c_branch2c"};
    run;
    
    /* res4c residual layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4c"
            layer={type='residual' act='RELU'} srcLayers={"res4b","bn4c_branch2c"};
    run;
    
    /* ------------------- Residual Layer 4D ----------------------- */
    
    /* res4d_branch2a convolution layer: 256 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4d_branch2a" 
            layer={type='convolution' nFilters=256 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res4c"};
    run;

    /* res4d_branch2a batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4d_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4d_branch2a"};
    run;

    /* res4d_branch2b convolution layer: 256 channels, 3x3 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4d_branch2b" 
            layer={type='convolution' nFilters=256 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4d_branch2a"};
    run;

    /* res4d_branch2b batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4d_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4d_branch2b"};
    run;
    
    /* res4d_branch2c layer: 1024 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4d_branch2c" 
            layer={type='convolution' nFilters=1024 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4d_branch2b"};
    run;

    /* res4d_branch2c batch norm layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4d_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res4d_branch2c"};
    run;
    
    /* res4d residual layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4d"
            layer={type='residual' act='RELU'} srcLayers={"res4c","bn4d_branch2c"};
    run;
    
    /* ------------------- Residual Layer 4E ----------------------- */
    
    /* res4e_branch2a convolution layer: 256 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4e_branch2a" 
            layer={type='convolution' nFilters=256 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res4d"};
    run;

    /* res4e_branch2a batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4e_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4e_branch2a"};
    run;

    /* res4e_branch2b convolution layer: 256 channels, 3x3 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4e_branch2b" 
            layer={type='convolution' nFilters=256 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4e_branch2a"};
    run;

    /* res4e_branch2b batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4e_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4e_branch2b"};
    run;
    
    /* res4e_branch2c layer: 1024 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4e_branch2c" 
            layer={type='convolution' nFilters=1024 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4e_branch2b"};
    run;

    /* res4e_branch2c batch norm layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4e_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res4e_branch2c"};
    run;
    
    /* res4e residual layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4e"
            layer={type='residual' act='RELU'} srcLayers={"res4d","bn4e_branch2c"};
    run;
     
    /* ------------------- Residual Layer 4F ----------------------- */
    
    /* res4f_branch2a convolution layer: 256 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4f_branch2a" 
            layer={type='convolution' nFilters=256 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res4e"};
    run;

    /* res4f_branch2a batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4f_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4f_branch2a"};
    run;

    /* res4f_branch2b convolution layer: 256 channels, 3x3 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4f_branch2b" 
            layer={type='convolution' nFilters=256 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4f_branch2a"};
    run;

    /* res4f_branch2b batch norm layer: 256 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4f_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res4f_branch2b"};
    run;
    
    /* res4f_branch2c layer: 1024 channels, 1x1 conv, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4f_branch2c" 
            layer={type='convolution' nFilters=1024 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn4f_branch2b"};
    run;

    /* res4f_branch2c batch norm layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="bn4f_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res4f_branch2c"};
    run;
    
    /* res4f residual layer: 1024 channels, output = 14 x 14 */
    AddLayer/model='ResNet50' name="res4f"
            layer={type='residual' act='RELU'} srcLayers={"res4e","bn4f_branch2c"};
    run;
    
    /* ------------- Layer 5A -------------------- */
    
    /* res5a_branch1 layer: 2048 channels, 1x1 conv, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5a_branch1" 
            layer={type='convolution' nFilters=2048 width=1 height=1 stride=2 noBias=TRUE act="IDENTITY"} srcLayers={"res4f"};
    run;

    /* res5a_branch1 batch norm layer: 2048 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="bn5a_branch1"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res5a_branch1"};
    run;

    /* res5a_branch2a layer: 512 channels, 1x1 conv, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5a_branch2a" 
            layer={type='convolution' nFilters=512 width=1 height=1 stride=2 noBias=TRUE act="IDENTITY"} srcLayers={"res4f"};
    run;

    /* res5a_branch2a batch norm layer: 512 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="bn5a_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res5a_branch2a"};
    run;

    /* res5a_branch2b layer: 512 channels, 3x3 conv, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5a_branch2b" 
            layer={type='convolution' nFilters=512 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn5a_branch2a"};
    run;

    /* res5a_branch2b batch norm layer: 512 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="bn5a_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res5a_branch2b"};
    run;

    /* res5a_branch2c layer: 2048 channels, 1x1 conv, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5a_branch2c" 
            layer={type='convolution' nFilters=2048 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn5a_branch2b"};
    run;

    /* res5a_branch2c batch norm layer: 2048 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="bn5a_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res5a_branch2c"};
    run;
    
    /* res5a residual layer: 2048 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5a"
            layer={type='residual' act='RELU'} srcLayers={"bn5a_branch2c","bn5a_branch1"};
    run;
    
    /* ------------------- Residual Layer 5B ----------------------- */
    
    /* res5b_branch2a convolution layer: 512 channels, 1x1 conv, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5b_branch2a" 
            layer={type='convolution' nFilters=512 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res5a"};
    run;

    /* res5b_branch2a batch norm layer: 512 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="bn5b_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res5b_branch2a"};
    run;

    /* res5b_branch2b convolution layer: 512 channels, 3x3 conv, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5b_branch2b" 
            layer={type='convolution' nFilters=512 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn5b_branch2a"};
    run;

    /* res5b_branch2b batch norm layer: 512 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="bn5b_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res5b_branch2b"};
    run;
    
    /* res5b_branch2c layer: 2048 channels, 1x1 conv, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5b_branch2c" 
            layer={type='convolution' nFilters=2048 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn5b_branch2b"};
    run;

    /* res5b_branch2c batch norm layer: 2048 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="bn5b_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res5b_branch2c"};
    run;
    
    /* res5b residual layer: 2048 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5b"
            layer={type='residual' act='RELU'} srcLayers={"res5a","bn5b_branch2c"};
    run;
    
    /* ------------------- Residual Layer 5C ----------------------- */
    
    /* res5c_branch2a convolution layer: 512 channels, 1x1 conv, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5c_branch2a" 
            layer={type='convolution' nFilters=512 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"res5b"};
    run;

    /* res5c_branch2a batch norm layer: 512 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="bn5c_branch2a"
            layer={type='batchnorm' act='RELU'} srcLayers={"res5c_branch2a"};
    run;

    /* res5c_branch2b convolution layer: 512 channels, 3x3 conv, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5c_branch2b" 
            layer={type='convolution' nFilters=512 width=3 height=3 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn5c_branch2a"};
    run;

    /* res5c_branch2b batch norm layer: 512 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="bn5c_branch2b"
            layer={type='batchnorm' act='RELU'} srcLayers={"res5c_branch2b"};
    run;
    
    /* res5c_branch2c layer: 2048 channels, 1x1 conv, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5c_branch2c" 
            layer={type='convolution' nFilters=2048 width=1 height=1 stride=1 noBias=TRUE act="IDENTITY"} srcLayers={"bn5c_branch2b"};
    run;

    /* res5c_branch2c batch norm layer: 2048 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="bn5c_branch2c"
            layer={type='batchnorm' act='IDENTITY'} srcLayers={"res5c_branch2c"};
    run;
    
    /* res5c residual layer: 2048 channels, output = 7 x 7 */
    AddLayer/model='ResNet50' name="res5c"
            layer={type='residual' act='RELU'} srcLayers={"res5b","bn5c_branch2c"};
    run;
    
    /* ------------------- final layers ---------------------- */
    
    /* pool5 layer: 2048 channels, 7x7 pooling, output = 1 x 1 */
    AddLayer/model='ResNet50' name="pool5" 
            layer={type='pooling' width=7 height=7 stride=7 pool='mean'} srcLayers={"res5c"};
    run;
     
    /* fc1000 output layer: 1000 neurons */ /* NOTE: still need to set inverted dropout */
    AddLayer/model='ResNet50' name="fc1000"
             layer={type='output' n=1000 act="SOFTMAX"} srcLayers={"pool5"};
    run;
