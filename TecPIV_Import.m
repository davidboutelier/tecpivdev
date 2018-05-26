function [ NumberImages,ImageWidth,ImageHeight ] = TecPIV_Import(IPath,ThisDataSetNumber,Iformat,TecPIVFolder)
%TecPIV_Import Import the dng or 16-bit tif images and place them in
%specific folder defined by input parameter IPath
% IPath: Cell array with fragments of path to where the images should be
% placed
% Iformat: Import DNG or Tiff files '.dng' or '.tif'
% Note: Function does not know anymore if images are raw or experiment

    if strcmp(Iformat,'.dng') == 1
        [NumberImages,ImageWidth,ImageHeight] = TecPIV_Import_DNG(IPath,ThisDataSetNumber,TecPIVFolder);
    else
        [NumberImages,ImageWidth,ImageHeight] = TecPIV_Import_TIF(IPath,ThisDataSetNumber,TecPIVFolder);
    end

end

