function YourGUI
k = 180; %W/m K
[h, qfa, qfb, qfd] = YourCalculation(k); 
f = figure;
handles.gfaPlot = plot(h,qfa,'k','DisplayName','qfa');
hold on;
handles.gfbPlot = plot(h,qfb,'b','DisplayName','qfb');
handles.gfdPlot = plot(h,qfd,'r','DisplayName','qfd');
xlabel('Convection coefficient, h(W/m^2 * K)');
ylabel('Heat rate,qf(W/m)');
title('Heat rate vs h for different boundary conditions');
legend('show')
handles.Slider = uicontrol('Parent',f,'Style','slider', ...
          'Position',[81,54,419,50],...
          'value',k,'min',15,'max',180, ...
          'Callback', {@yourSliderCallback, handles});
bgcolor = f.Color;
uicontrol('Parent',f,'Style','text','Position',[50,54,23,50],...
  'String','15','BackgroundColor',bgcolor);
uicontrol('Parent',f,'Style','text','Position',[500,54,23,50],...
  'String','180','BackgroundColor',bgcolor);
uicontrol('Parent',f,'Style','text','Position',[240,50,100,40],...
  'String','Conduction Coefficient, k(W/m K)', ...
          'backgroundColor',bgcolor);
end


function [h, qfa, qfb, qfd] = YourCalculation(k)
L = 10e-3; %m
t = 1e-3; %m
Tb = 100 + 273; %K
Tinf = 25 + 273; %K
h = linspace(10,1000,20);
m = sqrt(2 .* h ./ (k * t));
M = sqrt(2 .* h .* t .* k) .* (Tb-Tinf);
qfa = M .* (sinh(m .* L)+(h ./ (m .* k)) .* cosh(m .* L)) ./ ...
           (cosh(m .*L) + (h ./ (m .*k)).*sinh(m.*L));
qfb = M .* tanh(m.*L);
qfd = M;
end

function yourSliderCallback(SliderH, EventData, handles)
k = get(SliderH, 'Value');
[h, qfa, qfb, qfd] = YourCalculation(k);
set(handles.gfaPlot, 'YData', qfa);
set(handles.gfbPlot, 'YData', qfb);
set(handles.gfdPlot, 'YData', qfd);
end