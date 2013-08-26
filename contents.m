% baphy - Behavioral Auditory PHYsiology toolbox
%
% baphy.m - main baphy interface
% baphy_set_path.m - set paths for running baphy (inlcuding global BAPHYHOME)
% baphy_remote.m - online analysis tool
% meska_pca.m - launch Meska spike sorter
%
% Please follow these conventions for locating files:
%
% .\Modules\ - behavior control code
% .\Modules\RefTar - main module - ReferenceTarget
% .\Modules\RefTar\TrialObjects\ - experiment-level objects
% .\Modules\RefTar\BehaviorObjects\ - experiment-level objects
% .\Hardware\ - hardware objects and control programs ("IO*.m")
% .\SoundObjects\ - low-level sound objects (tone, torc, etc)
% .\Utilities\ - routines for file io and processing
% .\UtilitiesBernhard\ - Bernhard's utilities, generally common with MANTA
% .\Config\ - local configuration files. generally not included in the
%             SVN project
% .\Config\<labname>\ - files specific to a lab, chosen by BAPHY_LAB global.
%
%
