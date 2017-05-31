function fig_launcher
%FIG_LAUNCHER Window to launch the other windows
% License: https://carma.codeplex.com/license

    % Create and center main window
	version = 13.01;
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    handles.figure_launcher = figure( ...
        'Units','pixels', ...
        'Position',[0 0 600 350], ...
        'Name','CARMA: Continuous Affect Rating and Media Annotation', ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'NumberTitle','off', ...
        'Visible','off', ...
        'Color',defaultBackground);
    movegui(handles.figure_launcher,'center');
    set(handles.figure_launcher,'Visible','on');
    % Create UI elements
    handles.axis_title = axes(handles.figure_launcher,...
        'Units','normalized', ...
        'Position',[0.05 0.60 0.90 0.30], ...
        'Color',[0.2 0.2 0.2],...
        'Box','on','XTick',[],'YTick',[],...
        'ButtonDownFcn',@website);
    xlim([-1 1]); ylim([-1 1]);
    text(0,0,sprintf('CARMA v%.2f',version),'Color',[1 1 1],'FontSize',42,...
        'FontName','cambria','HorizontalAlignment','center',...
        'ButtonDownFcn',@website);
    handles.push_collect = uicontrol(handles.figure_launcher, ...
		'Style','pushbutton', ...
        'Units','Normalized', ...
        'Position',[0.05 0.10 0.25 0.40], ...
        'String','Collect', ...
        'FontSize',18, ...
        'Callback',@push_collect_Callback);
    handles.push_review = uicontrol(handles.figure_launcher, ...
		'Style','pushbutton', ...
        'Units','Normalized', ...
        'Position',[0.05 0.10 0.25 0.40], ...
        'String','Review', ...
        'FontSize',18, ...
        'Callback',@push_review_Callback);
    handles.push_configure = uicontrol(handles.figure_launcher, ...
		'Style','pushbutton', ...
        'Units','Normalized', ...
        'Position',[0.70 0.10 0.25 0.40], ...
        'String','Configure', ...
        'FontSize',18, ...
        'Callback',@push_configure_Callback);
    align([handles.push_collect,handles.push_review,handles.push_configure],'distribute','bottom');
    guidata(handles.figure_launcher,handles);
	addpath('Functions');
    % Configure default settings
    global settings;
    if isdeployed
        settings = importdata(fullfile(ctfroot,'CARMA','default.mat'));
    else
        settings = importdata('default.mat');
    end
    % Check that VLC is installed
    axctl = actxcontrollist;
    index = strcmp(axctl(:,2),'VideoLAN.VLCPlugin.2');
    if sum(index)==0
        choice = questdlg(sprintf('CARMA requires the free, open source VLC Media Player.\nPlease be sure to download the 64-bit Windows version.\nPlease be sure to enable the "ActiveX plugin" option.\nOpen download page?'),...
            'CARMA','Yes','No','Yes');
        switch choice
            case 'Yes'
                web('http://www.videolan.org/vlc/download-windows.html','-browser');
        end
        delete(handles.figure_launcher);
    end
    % Check for updates
    try
        rss = urlread('http://carma.codeplex.com/project/feeds/rss?ProjectRSSFeed=codeplex%3a%2f%2frelease%2fcarma');
        index = strfind(rss,'CARMA v');
        newest = str2double(rss(index(1)+7:index(1)+11));
        if version < newest
            choice = questdlg(sprintf('CARMA has detected that an update is available.\nOpen download page?'),...
                'CARMA','Yes','No','Yes');
            switch choice
                case 'Yes'
                    web('http://carma.codeplex.com/releases/','-browser');
            end
            delete(handles.figure_launcher);
        end
    catch
    end
end

function push_collect_Callback(~,~)
    global settings;
    if strcmp(settings.input,'Computer Mouse')
        fig_collect_mouse;
    elseif strcmp(settings.input,'USB Joystick')
        fig_collect_device;
    end
end

function push_review_Callback(~,~)
    fig_review;
end

function push_configure_Callback(~,~)
    fig_configure();
    uiwait(findobj('Name','CARMA: Configure'));
end

function website(~,~)
    choice = questdlg('Open CARMA website in browser?','CARMA','Yes','No','Yes');
    switch choice
        case 'Yes'
            web('http://carma.codeplex.com/','-browser');
        otherwise
            return;
    end
end