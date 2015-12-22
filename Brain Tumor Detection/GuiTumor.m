function varargout = GuiTumor(varargin)
% GUITUMOR MATLAB code for GuiTumor.fig
%      GUITUMOR, by itself, creates a new GUITUMOR or raises the existing
%      singleton*.
%
%      H = GUITUMOR returns the handle to a new GUITUMOR or the handle to
%      the existing singleton*.
%
%      GUITUMOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUITUMOR.M with the given input arguments.
%
%      GUITUMOR('Property','Value',...) creates a new GUITUMOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GuiTumor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GuiTumor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GuiTumor

% Last Modified by GUIDE v2.5 21-Dec-2015 17:19:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiTumor_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiTumor_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GuiTumor is made visible.
function GuiTumor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiTumor (see VARARGIN)

% Choose default command line output for GuiTumor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GuiTumor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GuiTumor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename pathname] = uigetfile({'*.png'},'File Selector');
 global global_image 
 if (pathname)
     handles.myImage = strcat(pathname, filename);
     axes(handles.axes1);
     imshow(handles.myImage);
    
    global_image = imread(strcat(pathname , filename));
 end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global global_image 
grayImage=rgb2gray(global_image);
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
% binaryImage = im2bw(grayImage); if we used this line it will delete the
% circular frame around the brain 
binaryImage = grayImage > 40; 
% Display the image.
%figure
%imshow(binaryImage)

% Get the skull only
%binaryImage = imfill(binaryImage, 'holes');
binaryImage = ExtractNLargestBlobs(binaryImage, 1); % de btala3 akbar object mn el sora
mask = bwconvhull(binaryImage);

% Get the masked image
maskedImage = grayImage; % Initialize
maskedImage(~mask) = 0;  % y3ne ba2olo en el 7agat ely mawgoda fel masked image w msh mawgoda fel mask set it = 0;

axes(handles.axes2);
imshow(maskedImage);
%meanFilter = fspecial('average', [3 3]);
%filteredmean=imfilter(maskedImage,meanFilter);

%result = imnoise(maskedImage,'salt & pepper',0.01);
% figure
% imshow(result);
%helpview(fullfile(docroot,'toolbox','visionhdl','visionhdl.map'),'visionhdlimagefilter')
% ************************Trying some Filters*****************************
% meanFilter = fspecial('average', [3 3]);
% maskedImage=imfilter(maskedImage,meanFilter);

%  maskedImage = medfilt2(maskedImage);

% maskedImage = ordfilt2(maskedImage,1,ones(3,3));
 
 


%Sharpening Image
SharpenedImage = imsharpen(maskedImage,'Radius',0.7,'Amount',1); % bye3ml sharpen lel edges
%figure, imshow(SharpenedImage);

%Enhancement
Enhance=imadjust(SharpenedImage); % btzabat contrast bta3 el image 3an tare2 enha bte3ml saturation
% lel high and low intensities
%figure,imshow(Enhance)
axes(handles.axes3);
imshow(Enhance);
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
axes(handles.axes4);
imshow(result);
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

% bw3 = medfilt2(bw3); lw 2abl el morphology esta5demna mean filter tumor
% hayeb2a awda7 aktar

% convert to binary image
B=im2bw(bw3,0.3);
% create kernels
K3 = ones(2,3);
SE =strel('disk',1);

% apply erosion then dilation
IM2 = imopen(B,SE);
% IM2 = 255 * uint8(IM2);
% IM2 = imgaussfilt(IM2,.7);
%figure,imshow(IM2);
axes(handles.axes5);
imshow(IM2);
%impixelinfo(IM2);
