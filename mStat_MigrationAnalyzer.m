function varargout = mStat_MigrationAnalyzer(varargin)

%-----------------MEANDER STATISTICS TOOLBOX. MStaT------------------------
% MStaT Migration Analyzer
% This module analysis the migration generated by a period of time, using 
% the same calculates of the Planar Geometry Module. The Migration Module 
% allows quantify the punctual migration and determinate the spatial
% variation of the migration along the study reach. Also MStaT users can
% determinate the migration directions of the natural channels.

% Collaborations
% Lucas Dominguez Ruben. UNL, Argentina

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mStat_MigrationAnalyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @mStat_MigrationAnalyzer_OutputFcn, ...
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


% --- Executes just before mStat_MigrationAnalyzer is made visible.
function mStat_MigrationAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for mStat_MigrationAnalyzer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%set_enable(handles,'init')

% Set the name and version
set(handles.figure1,'Name',['MStaT: Migration Analyzer '], ...
    'DockControls','off')

axes(handles.pictureReach);
axes(handles.signalvariation);
set_enable(handles,'init')
        
%data cursor type
dcm_objt0 = datacursormode(gcf);

set(dcm_objt0,'UpdateFcn',@mStat_myupdatefcnMigration);

set(dcm_objt0,'Displaystyle','Window','Enable','on');

pos = get(0,'userdata');
% Push messages to Log Window:
    % ----------------------------
    log_text = {...
        '';...
        ['%----------- ' datestr(now) ' ------------%'];...
        'LETs START!!!'};
    statusLogging(handles.LogWindow, log_text)


% --- Outputs from this function are returned to the command line.
function varargout = mStat_MigrationAnalyzer_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Toolbar Menu
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function filefunctions_Callback(hObject, eventdata, handles)
% empty


% --------------------------------------------------------------------
function openfunctions_Callback(hObject, eventdata, handles)
% empty

function newproject_Callback(hObject, eventdata, handles)
set_enable(handles,'init')

% Push messages to Log Window:
    % ----------------------------
    log_text = {...
        '';...
        ['%----------- ' datestr(now) ' ------------%'];...
        'New Project'};
    statusLogging(handles.LogWindow, log_text)


% --------------------------------------------------------------------
function closefunctions_Callback(hObject, eventdata, handles)
close


% --------------------------------------------------------------------
function initialtime_Callback(hObject, eventdata, handles)
set_enable(handles,'init')
handles.celltable=cell(2,3);

celltable(1:2,2:3)={''};
guidata(hObject,handles)

%This function incorporate the initial data
multisel='off';

persistent lastPath 
% If this is the first time running the function this session,
% Initialize lastPath to 0
if isempty(lastPath) 
    lastPath = 0;
end

%read file funtion
[ReadVar]=mStat_ReadInputFiles(multisel,lastPath);

% Use the path to the last selected file
% If 'uigetfile' is called, but no item is selected, 'lastPath' is not overwritten with 0
if ReadVar.Path ~= 0
    lastPath = ReadVar.Path;
end

if ReadVar.File==0
else
    
    % Push messages to Log Window:
    % ----------------------------
    log_text = {...
                '';...
                ['%--- ' datestr(now) ' ---%'];...
                'Final Time Centerline Loaded:';[cell2mat({ReadVar.File})]};
                statusLogging(handles.LogWindow, log_text)
                
    %Convert information
    handles.xCoord=[];
    handles.yCoord=[];
    handles.xCoord{1}(:,1)=ReadVar.xCoord{:,1};
    handles.yCoord{1}(:,1)=ReadVar.yCoord{:,1};
    handles.formatfileread=ReadVar.comp;
    guidata(hObject, handles);
    
    
    %Write File name
    celltable(1,1)={ReadVar.File};
    set(handles.sedtable,'Data',celltable)      
    
    %plot
    axes(handles.pictureReach)
    plot(handles.xCoord{1}(:,1),handles.yCoord{1}(:,1),'-b')%start
    hold on
    legend('t0','Location','Best') 
    grid on
    axis equal

    xlabel('X [m]');ylabel('Y [m]')
    hold off
    
end


% --------------------------------------------------------------------
function finaltime_Callback(hObject, eventdata, handles)
%This function read Centerline final time
celltable=get(handles.sedtable,'Data');

% This function incorporate the initial data
multisel='off';%Multiselect off
persistent lastPath 
% If this is the first time running the function this session,
% Initialize lastPath to 0
if isempty(lastPath) 
    lastPath = 0;
end

%read file funtion
[ReadVar]=mStat_ReadInputFiles(multisel,lastPath);

% Use the path to the last selected file
% If 'uigetfile' is called, but no item is selected, 'lastPath' is not overwritten with 0
if ReadVar.Path ~= 0
    lastPath = ReadVar.Path;
end

if ReadVar.File==0
else
    
    % Push messages to Log Window:
    % ----------------------------
    log_text = {...
                '';...
                ['%--- ' datestr(now) ' ---%'];...
                'Final Time Centerline Loaded:';[cell2mat({ReadVar.File})]};
                statusLogging(handles.LogWindow, log_text)
                
    % Convert information            
    handles.xCoord{2}(:,1)=ReadVar.xCoord{:,1};
    handles.yCoord{2}(:,1)=ReadVar.yCoord{:,1};
    handles.formatfileread=ReadVar.comp;
    guidata(hObject, handles);
    set_enable(handles,'loadfiles')
    
    %Write File name
    celltable(2,1)={ReadVar.File};
    set(handles.sedtable,'Data',celltable) 
    
    %plot
    axes(handles.pictureReach)

    plot(handles.xCoord{1}(:,1),handles.yCoord{1}(:,1),'-b')%start
    hold on
    plot(handles.xCoord{2}(:,1),handles.yCoord{2}(:,1),'-k')%start
    legend('t0','t1','Location','Best') 
    grid on
    axis equal

    xlabel('X [m]');ylabel('Y [m]')
    hold off
    
end


% --------------------------------------------------------------------
function export_Callback(hObject, eventdata, handles)
% empty


% --------------------------------------------------------------------
function matfiles_Callback(hObject, eventdata, handles)
%This function sae in matlab format the output data
hwait = waitbar(0,'Exporting .mat File...');

%Read Data
geovar = getappdata(0, 'geovarf');
Migra = getappdata(0, 'Migra');

[file,path] = uiputfile('*.mat','Save file');
save([path file], 'geovar','Migra');
waitbar(1,hwait)
delete(hwait)

% Push messages to Log Window:
% ----------------------------
log_text = {...
    '';...
    ['%----------- ' datestr(now) ' ------------%'];...
    'Export MAT file succesfully'};
statusLogging(handles.LogWindow, log_text)


% --------------------------------------------------------------------
function summary_Callback(hObject, eventdata, handles)
mStat_SummaryMigration(handles.Migra);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate
% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
%Run the calculate function
hwait = waitbar(0,'Migration Calculate. Processing...','Name','MStaT',...
         'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
setappdata(hwait,'canceling',0)

tableData = get(handles.sedtable, 'data');
% Clean the GUI
cla(handles.wavel_axes)
%cla(handles.pictureReach)
cla(handles.signalvariation)
linkaxes(handles.signalvariation)
delete(allchild(handles.signalvariation))

%Read GUI data
handles.width=str2double(cellstr(tableData(:,3)));
handles.year=str2double(cellstr(tableData(:,2)));

%Init Calculate
sel=2;%Inflection points default method
handles.bendSelect=[];%none data
Tools=2;%Migration Module
level=5;%filter level default
for i=1:2
    [geovar{i}]=mStat_planar(handles.xCoord{i},handles.yCoord{i},...
        handles.width(i),sel,handles.pictureReach,handles.bendSelect,Tools,level);
    % Waitbar shows the the user the status
    waitbar((40+(i*10))/100,hwait);
end

%save data
setappdata(0, 'geovarf', geovar);
handles.geovar=geovar;
guidata(hObject,handles)

%Calculate the migration using vectors
[Migra,ArMigra]=mStat_Migration(geovar,handles);

% Waitbar shows the the user the status
waitbar(80/100,hwait);

%save data
handles.Migra=Migra;
handles.ArMigra=ArMigra;
guidata(hObject,handles)

%store data
setappdata(0, 'Migra', Migra);
setappdata(0, 'ArMigra', ArMigra);
setappdata(0, 'handles', handles);

set_enable(handles,'results')


% Push messages to Log Window:
% ----------------------------
log_text = {...
    '';...
    ['%----------- ' datestr(now) ' ------------%'];...
    'Calculate finished';...
    'Summary:';...
    'Mean Migration/year';[cell2mat({nanmean(Migra.MigrationSignal)/Migra.deltat})];...
    'Maximum Migration';[cell2mat({nanmax(Migra.MigrationSignal)})];...
    'Minimum Migration';[cell2mat({nanmin(Migra.MigrationSignal)})];...
    'Cutoff Found';[cell2mat({Migra.NumberOfCut})]};
statusLogging(handles.LogWindow, log_text)

waitbar(1,hwait)
delete(hwait)


% --- Executes on button press in identifycutoff.
function identifycutoff_Callback(hObject, eventdata, handles)
%read variables
Migra=handles.Migra;

%Indentify cutoff using wavelength

if Migra.NumberOfCut == 0
   warndlg('Doesn�t found Cutoff')
  else     
    axes(handles.pictureReach)
    hold on
    ee=text(handles.ArMigra.xint_areat0(Migra.BendCutOff),handles.ArMigra.yint_areat0(Migra.BendCutOff),'Cutoff');
    set(ee,'Clipping','on')
    handles.highlightPlot = line(Migra.linet1X{Migra.BendCutOff}.line, Migra.linet1Y{Migra.BendCutOff}.line,...
            'color', 'y', 'LineWidth',3); 
    hold off
 end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%Extra Function
%%%%%%%%%%%%%%%%%%%%%%%%%%

function set_enable(handles,enable_state)
%Set initial an load files
switch enable_state
    case 'init'
        axes(handles.signalvariation)
        cla reset
        grid on
        axes(handles.wavel_axes)
        cla reset
        grid on
        axes(handles.pictureReach)
        cla reset
        grid on
        set(handles.calculate,'Enable','off');
        set(handles.sedtable, 'RowName', {'t0','t1'});
        set(handles.sedtable, 'Data', cell(2,3));
        set(findall(handles.cutoffpanel, '-property', 'enable'), 'enable', 'off')
        set(findall(handles.panelresults, '-property', 'enable'), 'enable', 'off')
        set(handles.vectorsgraph,'Enable','off');
        set(handles.export,'Enable','off');
        set(handles.summary,'Enable','off');
    case 'loadfiles'
        cla(handles.signalvariation)
        %set(handles.sedtable, 'Data', cell(2,3));
        cla(handles.wavel_axes)
        set(handles.calculate,'Enable','on');
        set(findall(handles.panelresults, '-property', 'enable'), 'enable', 'on')
        set(handles.vectorsgraph,'Enable','off');
    case 'results'
        set(findall(handles.cutoffpanel, '-property', 'enable'), 'enable', 'on')
        set(handles.summary,'Enable','on');
        set(handles.export,'Enable','on');
        set(handles.vectorsgraph,'Enable','on');
    otherwise
end


% --- Executes on selection change in LogWindow.
function LogWindow_Callback(hObject, eventdata, handles)
% empty


% --- Executes during object creation, after setting all properties.
function LogWindow_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in predictor.
function predictor_Callback(hObject, eventdata, handles)
%Compare the arcwaelength with the width of the channel ande predict the
%posibility of neck cut off
%Read data 
geovar = getappdata(0, 'geovarf');

f=0;%doesnt have predictors

for u=1:length(geovar{2}.wavelengthOfBends)
    if geovar{2}.wavelengthOfBends(u)<2*geovar{2}.width
        f=1;
        % Call the "userSelectBend" function to get the index of intersection
        % points and the highlighted bend limits.  

        [highlightX, highlightY, ~] = userSelectBend(geovar{2}.intS, u,...
            geovar{2}.equallySpacedX,geovar{2}.equallySpacedY,geovar{2}.newInflectionPts,...
            geovar{2}.sResample);
        handles.highlightX = highlightX;
        handles.highlightY = highlightY;

        axes(handles.pictureReach);
        % hold on
        handles.highlightPlot = line(handles.highlightX(1,:), handles.highlightY(1,:),...
            'color', 'y', 'LineWidth',8); 

        guidata(hObject,handles)
    end
end

if f==1
else
    warndlg('Doesn�t found bends')
end





% --- Executes on button press in vectorsgraph.
function vectorsgraph_Callback(hObject, eventdata, handles)

switch get(handles.vectorsgraph,'value')   % Get Tag of selected object
    case 0
                %Run the calculate function
        hwait = waitbar(0,'Creating plot...','Name','MStaT',...
                 'CreateCancelBtn',...
                    'setappdata(gcbf,''canceling'',1)');
        setappdata(hwait,'canceling',0)

        %Read Data
        geovar = getappdata(0, 'geovarf');
        ArMigra = getappdata(0, 'ArMigra');
        axes(handles.pictureReach)
        plot(geovar{1}.equallySpacedX,geovar{1}.equallySpacedY,'-b')%start
        hold on
        plot(geovar{2}.equallySpacedX,geovar{2}.equallySpacedY,'-k')%start
        plot(ArMigra.xint_areat0,ArMigra.yint_areat0,'or')
        legend('t0','t1','Intersection','Location','Best')   
        grid on
        axis equal
        xlabel('X [m]');ylabel('Y [m]')
        hold off
        waitbar(1,hwait)
        delete(hwait)
        
    case 1
        
        %Run the calculate function
        hwait = waitbar(0,'Creating plot...','Name','MStaT',...
                 'CreateCancelBtn',...
                    'setappdata(gcbf,''canceling'',1)');
        setappdata(hwait,'canceling',0)

        %Read Data
        geovar = getappdata(0, 'geovarf');
        Migra = getappdata(0, 'Migra');
        ArMigra = getappdata(0, 'ArMigra');
        
        axes(handles.pictureReach)
        plot(geovar{1}.equallySpacedX,geovar{1}.equallySpacedY,'-b')%start
        hold on
        plot(geovar{2}.equallySpacedX,geovar{2}.equallySpacedY,'-k')%start
        plot(ArMigra.xint_areat0,ArMigra.yint_areat0,'or')
        legend('t0','t1','Intersection','Location','Best')   
        grid on
        axis equal
        for t=2:length(Migra.xlinet1_int)

            D=[Migra.xlinet1_int(t) Migra.ylinet1_int(t)]-[Migra.xlinet0_int(t) Migra.ylinet0_int(t)];
            quiver(Migra.xlinet0_int(t),Migra.ylinet0_int(t),D(1),D(2),0,'filled','color','k','MarkerSize',10)

      %       waitbar(((t/length(Migra.xlinet1_int))/50)/100,hwait); 
        end
        waitbar(50/100,hwait); 
        % 
        xlabel('X [m]');ylabel('Y [m]')
        hold off


        %Plot maximum migration
        axes(handles.pictureReach)
        hold on

        %Found maximum migration
        Controlmax=Migra.MigrationSignal;
        [~,pos]=nanmax(Controlmax);

        %Control maximum migration
        r=1;
        while(Controlmax(pos)- Controlmax(pos-1))/Controlmax(pos)>0.5
            Controlmax(pos)=[];
            [~,pos]=nanmax(Controlmax);
            r=r+1;
        end

        ee=text(Migra.xlinet1_int(pos),Migra.ylinet1_int(pos),'Maximum Migration');
        set(ee,'Clipping','on')

        hold off
        waitbar(1,hwait)
        delete(hwait)

    otherwise
       % Code for when there is no match.

end
