function [ listout ] = removeblanks(listin  )
% function [ listout ] = removeblanks(listin  )
%   Remove blanks from a cell array
%
%-------------------------------------------------------------------------
% QUESTIONS, COMMENTS, FEEDBACK
% Michael Rowlands - v1.0 2017-05-24
% Engineering in the 21st century; Make It Easy !
% easineering@gmail.com
%-------------------------------------------------------------------------

ct = 1;
z = length(listin);
while ct<=z
    if length(listin{ct})==0
        listin(ct)=[];
        z = z- 1;
    else
        ct = ct+1;
    end
end

listout = listin;
