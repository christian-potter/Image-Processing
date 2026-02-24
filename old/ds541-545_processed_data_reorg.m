%% 541-545 Processed File Reorganization 
[zstack,tseries_md,zstack_md,tsync,s2p,ypix_zplane] = utils.load_drgs(545,)%%
%% GET STIMS
dsstim=load("\\SMB1.neurobio.pitt.edu\Ross\Christian\DRGS\ds_variables6.mat"); 
%% BASE FOLDER
%base = '\\Shadowfax\Warwick\DRGS project\#541 3-22-25\SDH\Processed\';
%base = '\\Shadowfax\Warwick\DRGS project\#545 4-4-25\SDH\Processed\';
%base = '\\Shadowfax\Warwick\DRGS project\#547 8-6-25\SDH\Processed\';
base = '\\Shadowfax\Warwick\DRGS project\#548 8-8-25\SDH\Processed\';
%% SAVE STIM
stim = dsstim.stim(4);
fn = [base,'stim.mat']; 
save(fn,'stim')

%% GET ZSTACK_MD
zstack_mdpath = '\\Shadowfax\Warwick\DRGS project\#545 4-4-25\SDH\Structural\Final Z Stack\Experiment.xml'; 
zstack_xml = md.importxml(zstack_mdpath); 
[zstack_md]=md.extract_metadata(zstack_xml);
%% FALL
Fall = load("\\Shadowfax\Warwick\DRGS project\#547 8-6-25\SDH\Processed\Fall.mat");
fn = [base,'Fall_variables.mat'];
save(fn,"Fall")


%% SAVE ZSTACK METADATA
fn = [base,'zstack_md.mat'];
save(fn,'zstack_md')


%% SAVE ZSTACK
fn = ["\\Shadowfax\Warwick\DRGS project\#547 8-6-25\SDH\Structural\Final Z Stack.tif"];
zstack= get.zstack(fn);
fn = [base,'zstack.mat'];
save(fn,'zstack')

%% SAVE TSERIES_MD
%tseries_md = load("\\Shadowfax\Warwick\DRGS project\#545 4-4-25\SDH\Processed\tseries_md.mat");
fn = [base,'tseries_md.mat'];
save(fn,'tseries_md');

%% TEST 
[Fall,tseries_md,zstack,zstack_md,tsync] =utils.load_Data_Organization('541');

%%