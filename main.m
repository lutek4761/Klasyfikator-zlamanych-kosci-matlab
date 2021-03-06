clc, clear, close all

path = '.\dataset2';
imds = imageDatastore(path, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');

%Obliczenie liczby kategorii
labelCount = countEachLabel(imds);
classes_num = height(labelCount);

%Okreslenie rozmiaru obrazka na potrzeby warstwy wejsciowej
img = readimage(imds,1);
imgSize = [size(img) 1];


%Podzielenie zestawu na dane uczace i testowe
numTrainFiles = 20;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

%Augmentacja danych
imageAugmenter = imageDataAugmenter( ...
    'RandRotation',[-20,20], ...
    'RandXTranslation',[-3 3], ...
    'RandYTranslation',[-3 3], ...
    'RandXReflection', true, ...
    'RandYReflection', true, ...
    'RandXShear', [-5 5], ...
    'RandYShear', [-5 5]);

augimds = augmentedImageDatastore(size(img), imdsTrain, ...
    'DataAugmentation',imageAugmenter, ...
    'ColorPreprocessing', 'rgb2gray');

%Stworzenie warstw, konwolucje, max pooling, full connected, softmax
layers = [
    imageInputLayer(size(img))
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(classes_num)
    softmaxLayer
    classificationLayer];

%opcje procesu uczenia
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',100, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

%trening sieci
net = trainNetwork(augimds,layers,options);

%walidacja
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation);