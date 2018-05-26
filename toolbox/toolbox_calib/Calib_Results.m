% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 2945.121313433014600 ; 2943.407554780836100 ];

%-- Principal point:
cc = [ 1967.553504207442300 ; 1313.913196953635900 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ -0.193449272460488 ; 0.106755300195226 ; -0.001406572011525 ; -0.000025159004959 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 2.364405953164078 ; 2.233052003630731 ];

%-- Principal point uncertainty:
cc_error = [ 2.292302327819130 ; 1.737371494288935 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.002391787569650 ; 0.008852859164937 ; 0.000122587081099 ; 0.000144162411418 ; 0.000000000000000 ];

%-- Image size:
nx = 3906;
ny = 2602;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 7;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 1;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ -3.063985e+00 ; -1.180856e-02 ; 2.891788e-02 ];
Tc_1  = [ -1.737929e+02 ; 1.299897e+02 ; 4.258792e+02 ];
omc_error_1 = [ 6.778503e-04 ; 1.409172e-04 ; 1.238248e-03 ];
Tc_error_1  = [ 3.369905e-01 ; 2.549927e-01 ; 3.737409e-01 ];

%-- Image #2:
omc_2 = [ -2.975784e+00 ; 1.690580e-02 ; -7.271926e-01 ];
Tc_2  = [ -1.587032e+02 ; 1.319398e+02 ; 4.094277e+02 ];
omc_error_2 = [ 7.434237e-04 ; 2.660858e-04 ; 1.215844e-03 ];
Tc_error_2  = [ 3.302200e-01 ; 2.478048e-01 ; 3.647422e-01 ];

%-- Image #3:
omc_3 = [ -3.019481e+00 ; -3.522305e-02 ; 5.800415e-01 ];
Tc_3  = [ -1.873082e+02 ; 1.247955e+02 ; 5.285203e+02 ];
omc_error_3 = [ 6.983851e-04 ; 2.400448e-04 ; 1.247827e-03 ];
Tc_error_3  = [ 4.128539e-01 ; 3.139795e-01 ; 4.087763e-01 ];

%-- Image #4:
omc_4 = [ 2.975961e+00 ; 3.609137e-02 ; 7.851471e-02 ];
Tc_4  = [ -1.957729e+02 ; 1.115090e+02 ; 4.185854e+02 ];
omc_error_4 = [ 7.197041e-04 ; 1.667185e-04 ; 1.223751e-03 ];
Tc_error_4  = [ 3.345429e-01 ; 2.588313e-01 ; 3.912622e-01 ];

%-- Image #5:
omc_5 = [ 2.889504e+00 ; 9.179675e-02 ; 7.686982e-01 ];
Tc_5  = [ -1.569802e+02 ; 1.050888e+02 ; 3.832083e+02 ];
omc_error_5 = [ 6.957801e-04 ; 2.809237e-04 ; 1.201884e-03 ];
Tc_error_5  = [ 3.114233e-01 ; 2.338956e-01 ; 3.680270e-01 ];

%-- Image #6:
omc_6 = [ -2.845734e+00 ; 1.705277e-02 ; -3.017504e-02 ];
Tc_6  = [ -1.831610e+02 ; 1.386982e+02 ; 4.655241e+02 ];
omc_error_6 = [ 6.580705e-04 ; 2.164620e-04 ; 1.161369e-03 ];
Tc_error_6  = [ 3.661328e-01 ; 2.766928e-01 ; 3.926837e-01 ];

%-- Image #7:
omc_7 = [ -2.785377e+00 ; -8.075565e-02 ; 6.101730e-01 ];
Tc_7  = [ -1.931568e+02 ; 1.079868e+02 ; 5.686679e+02 ];
omc_error_7 = [ 6.804232e-04 ; 2.950594e-04 ; 1.148400e-03 ];
Tc_error_7  = [ 4.447188e-01 ; 3.391878e-01 ; 4.061647e-01 ];

