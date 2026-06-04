function [t_ps, y] = read_td(fname)
%READ_TD Load a Menlo ScanControl trace or FFT export.
%   [t_ps, y] = READ_TD(fname) returns the first column (time in ps, or
%   frequency in THz for *_fft.txt files) and the second column (THz
%   signal, a.u.). Unlike the course-provided read_TD_file.m, the '#'
%   header lines are skipped automatically, so the raw files need not be
%   edited (they must never be modified).
    A = readmatrix(fname, 'FileType', 'text', 'CommentStyle', '#');
    t_ps = A(:,1);
    y    = A(:,2);
end
