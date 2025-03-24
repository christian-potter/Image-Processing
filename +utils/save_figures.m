function save_figures(fignum,filename,opt)
arguments
    fignum 
    filename 
    opt.print logical = false
end

fignum = double(fignum); 


if ~opt.print

    if ismac
        try
            saveas(fignum,['/Users/christianpotter/Library/Mobile Documents/com~apple~CloudDocs/F31/Resubmission/Matlab Figures',filename],'pdf')
            %saveas(fignum,['/Users/christianpotter/Library/Mobile Documents/com~apple~CloudDocs/F31/Resubmission/Matlab Figures/',filename],'fig')
          
        catch
            saveas(fignum,['/Volumes/ross/Christian/Matlab Figures/',filename],'pdf')
            %saveas(fignum,['/Volumes/ross/Christian/Matlab Figures/',filename],'fig')
        end
    
    end

elseif opt.print 

    fig = gcf; 
    print(['/Users/christianpotter/Library/Mobile Documents/com~apple~CloudDocs/F31/Resubmission/Matlab Figures/',filename],'-dpdf','-fillpage','-vector')

end
