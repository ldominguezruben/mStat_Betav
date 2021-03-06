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

warning off

% Update handles structure
guidata(hObject, handles);

%set_enable(handles,'init')

% Set the name and version
set(handles.figure1,'Name',['MStaT: Migration Module '], ...
    'DockControls','off')

axes(handles.pictureReach);
axes(handles.signalvariation);
set_enable(handles,'init')
        
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
set_enable(handles,'init')

handles.Module = 2;
handles.multisel = 'on';
handles.first=1;
guidata(hObject,handles)

%read file funtion
mStat_ReadInputFiles(handles);

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
function graphs_Callback(hObject, eventdata, handles)
% empty


% --------------------------------------------------------------------
function plainviewgraph_Callback(hObject, eventdata, handles)
h=figure('Name','MStaT: River Migration','NumberTitle','off');
set(h, 'Position', [10 10 550 500])
AxesH = handles.pictureReach;
fig=copyobj(AxesH,h);
set(fig,'Units', 'normalized', 'Position', [.1 .1 .85 .8]);


% --------------------------------------------------------------------
function migrationgraph_Callback(hObject, eventdata, handles)
h=figure('Name','MStaT: River Centerlines','NumberTitle','off');
set(h, 'Position', [10 10 550 300])
AxesH = handles.signalvariation;
fig=copyobj(AxesH,h);
set(fig,'Units', 'normalized', 'Position', [.1 .15 .85 .75]);



% --------------------------------------------------------------------
function waveletgraph_Callback(hObject, eventdata, handles)
h=figure('Name','MStaT: River Centerlines','NumberTitle','off');
set(h, 'Position', [10 10 550 300])
AxesH = handles.wavel_axes;
fig=copyobj(AxesH,h);
set(fig,'Units', 'normalized', 'Position', [.15 .15 .85 .75]);
cc=colorbar;
colormap('jet');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate
% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
tableData = get(handles.sedtable, 'data');
handles.year=str2double(cellstr(tableData(:,2)));
if isnan(handles.year(1))
    warndlg('Please add the year of t0 in format YYYY')
elseif length(handles.year)==1
    warndlg('Please add the river centerline of t1')
elseif isnan(handles.year(2))
    warndlg('Please add the year of t1 in format YYYY')
else
%Run the calculate function
geovar = getappdata(0, 'geovar');
ReadVar = getappdata(0, 'ReadVar');

hwait = waitbar(0,'Migration Calculate. Processing...','Name','MStaT',...
         'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
setappdata(hwait,'canceling',0)

tableData = get(handles.sedtable, 'data');
% Clean the GUI
cla(handles.wavel_axes)
cla(handles.signalvariation)
linkaxes(handles.signalvariation)
delete(allchild(handles.signalvariation))

%Read GUI data

for i=1:length(ReadVar)
    width(i)=ReadVar{i}.width;
end

handles.year=str2double(cellstr(tableData(:,2)));

if width(1)>width(2)
    ReadVar{2}=ReadVar{1};
    ReadVar{1}=ReadVar{2};
    geovar{2}=geovar{1};
    geovar{1}=geovar{2};
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
    'Mean Migration/year';[round(cell2mat({nanmean(Migra.MigrationSignal)/Migra.deltat}),2)];... 
    'Maximum Migration';[round(cell2mat({nanmax(Migra.MigrationSignal)}),2)];...
    'Minimum Migration';[round(cell2mat({nanmin(Migra.MigrationSignal)}),2)];...
    'Cutoff Found';[cell2mat({Migra.NumberOfCut})]};
statusLogging(handles.LogWindow, log_text)

waitbar(1,hwait)
delete(hwait)
end


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
    for i=1:length(Migra.BendCutOff)
        handles.highlightPlot = line(Migra.linet1X{Migra.BendCutOff(i)}.line, Migra.linet1Y{Migra.BendCutOff(i)}.line,...
            'color', 'y', 'LineWidth',3); 
    end
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
        set(handles.sedtable, 'Data', cell(2,2));
        set(findall(handles.cutoffpanel, '-property', 'enable'), 'enable', 'off')
        set(findall(handles.panelresults, '-property', 'enable'), 'enable', 'off')
        set(handles.vectorsgraph,'Enable','off');
        set(handles.export,'Enable','off');
        %set(handles.summary,'Enable','off');
    case 'loadfiles'
        cla(handles.signalvariation)
        %set(handles.sedtable, 'Data', cell(2,3));
        cla(handles.wavel_axes)
        set(handles.calculate,'Enable','on');
        set(findall(handles.panelresults, '-property', 'enable'), 'enable', 'on')
        set(handles.vectorsgraph,'Enable','off');
    case 'results'
        set(findall(handles.cutoffpanel, '-property', 'enable'), 'enable', 'on')
        %set(handles.summary,'Enable','on');
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


% --- Executes on button press in vectorsgraph.
function vectorsgraph_Callback(hObject, eventdata, handles)

switch get(handles.vectorsgraph,'value')   % Get Tag of selected object
    case 0 %without vectors
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
        plot(geovar{1}.equallySpacedX(1,1), geovar{1}.equallySpacedY(1,1),'*',    'MarkerSize',14,...
        'MarkerEdgeColor','b','MarkerFaceColor','b');
        plot(ArMigra.xint_areat0,ArMigra.yint_areat0,'or')
        legend('t0','t1','Intersection','Upstream','Location','Best')   
        grid on
        axis equal
        xlabel('X [m]');ylabel('Y [m]')
        hold off
        waitbar(1,hwait)
        delete(hwait)
        
    case 1 % with vectors        
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
        %figure(5)
        plot(geovar{1}.equallySpacedX,geovar{1}.equallySpacedY,'-b')%start
        hold on
        plot(geovar{2}.equallySpacedX,geovar{2}.equallySpacedY,'-k')%start
        plot(geovar{1}.equallySpacedX(1,1), geovar{1}.equallySpacedY(1,1),'*',    'MarkerSize',14,...
        'MarkerEdgeColor','b','MarkerFaceColor','b');
        plot(ArMigra.xint_areat0,ArMigra.yint_areat0,'or')
        legend('t0','t1','Intersection','Upstream','Location','Best')   
        grid on
        axis equal
        for t=2:length(Migra.xlinet1_int)

            D=[Migra.xlinet1_int(t) Migra.ylinet1_int(t)]-[Migra.xlinet0_int(t) Migra.ylinet0_int(t)];
            quiver(Migra.xlinet0_int(t),Migra.ylinet0_int(t),D(1),D(2),0,'filled','color','k','MarkerSize',10,'MaxHeadSize',3)

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


% --------------------------------------------------------------------
function datacursor_OnCallback(hObject, eventdata, handles)
axes(handles.pictureReach); 

%data cursor type
dcm_obj = datacursormode(gcf);

set(dcm_obj,'UpdateFcn',@mStat_myupdatefcn);

set(dcm_obj,'Displaystyle','Window','Enable','on');
pos = get(0,'userdata');


% --- Executes when entered data in editable cell(s) in sedtable.
function sedtable_CellEditCallback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function sedtable_CreateFcn(hObject, eventdata, handles)
% empty


% --- Executes on key press with focus on sedtable and none of its controls.
function sedtable_KeyPressFcn(hObject, eventdata, handles)
% empty


% --- Executes when selected cell(s) is changed in sedtable.
function sedtable_CellSelectionCallback(hObject, eventdata, handles)
% empty


% --------------------------------------------------------------------
function ruler_OnCallback(hObject, eventdata, handles)
axes(handles.pictureReach)
%imdistline(hparent)

 axis manual
 handles.Figruler = imline(gca);
 % Get original position
 pos = getPosition(handles.Figruler);
 % Get updated position as the ruler is moved around
 id = addNewPositionCallback(handles.Figruler,@(pos) title(mat2str(pos,3)));
 
 x=pos(:,1);
 y=pos(:,2);
 
 handles.ruler=imdistline(handles.pictureReach,x,y);
 guidata(hObject,handles)


% --------------------------------------------------------------------
function ruler_OffCallback(hObject, eventdata, handles)
 delete(handles.ruler)
 delete(handles.Figruler)
