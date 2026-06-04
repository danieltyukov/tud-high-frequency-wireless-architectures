function [ X , Y ] = read_TD_file(file_name) %remember to delete the header of the .txt file
    fid = fopen( file_name, 'r' );    
    
    formatSpec = '%f';
    sizeA = [2 Inf];
        
    A = fscanf(fid,formatSpec,sizeA) ;
    X = A(1,:) ;
    Y = A(2,:) ;    
    
    fclose(fid);
end
