im=imread('brain.png');
%step 2 Pre-Processing Stage step 2


grayImage=rgb2gray(im);
% im(row1:row2, col1:col2) = 0;

[rows, columns, numberOfColorBands] = size(grayImage);
if numberOfColorBands > 1
	% It's not really gray scale like we expected - it's color.
	% Convert it to gray scale by taking only the green channel.
	grayImage = grayImage(:, :, 2); % Take green channel.
end
% figure
% imshow(grayImage);

% Binarize the image
binaryImage = grayImage > 40;
% Display the image.
%figure
%imshow(binaryImage)

% Get the skull only
binaryImage = imfill(binaryImage, 'holes');
binaryImage = ExtractNLargestBlobs(binaryImage, 1);
mask = bwconvhull(binaryImage);
% Get the masked image
maskedImage = grayImage; % Initialize
maskedImage(~mask) = 0; 
%figure,imshow(maskedImage);
%meanFilter = fspecial('average', [3 3]);
%filteredmean=imfilter(maskedImage,meanFilter);

%result = imnoise(maskedImage,'salt & pepper',0.01);
% figure
% imshow(result);
%helpview(fullfile(docroot,'toolbox','visionhdl','visionhdl.map'),'visionhdlimagefilter')

%Sharpening Image
SharpenedImage = imsharpen(maskedImage,'Radius',2,'Amount',1);
%figure, imshow(SharpenedImage);

%Enhancement
Enhance=imadjust(SharpenedImage);
figure,imshow(Enhance)

%Thresholding 

 
[r,c] = size(Enhance);
result = zeros(r,c);
for i=1:r
    for j=1:c
        if Enhance(i,j) > 190
            result(i,j) = 1;
        end
    end
end
%figure,imshow(result);

%WaterShed
 
L = watershed(result);
Lrgb = label2rgb(L);
%figure,imshow(Lrgb)
bw2 = ~bwareaopen(~result, 10);
%imshow(bw2)
D = -bwdist(~result);
%figure,imshow(D,[])
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = result;
bw3(Ld2 == 0) = 0;
%figure,imshow(bw3)

%Morphology 

% convert to binary image
B=im2bw(bw3,0.3);
% create kernels

SE =strel('disk',1);

% apply erosion then dilation
IM2 = imopen(B,SE);


figure,imshow(IM2);
