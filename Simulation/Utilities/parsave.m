function parsave(file, x)
%     evalin('base',strcat("save('",file,"')"));
evalin('base',"gameObj")
%     assignin('base', file, x);
end

