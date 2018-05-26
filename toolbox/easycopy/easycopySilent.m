function dataout = easycopy(varargin)
% function dataout = easycopy(varargin)
% easycopy(source,dest,[sourcedir],[destdir],'findreplaceoption')
%
% This function takes a list of source files and a list of destination
% filenames and copies the source to the corresponding destination.
%
% source = single filename or list of files
% dest = single filename or list of files
% sourcedir = source directory for all the source file list
% destdir = destination directory for all the dest file lists
%
% This function was written to solve a particular filename problem.  I had a bunch
% of measured files from the lab named:
%
%   IL_test2.s4p
%   FEXT_Test4_try2.s4p
%   NEXT_try3_TEST6.s4p
%   (Notice the mix of upper and lower case letters, plus the "try.." notes
%   for some measurements. )
%
%   There is a customer-required tool that takes these files and makes a report, and it can only read
%   files named like this:  (Each file must start with "Test#...")
%
%   Test2_IL.s4p
%   Test4_FEXT_try2.s4p
%   Test6_NEXT_try3.s4p
%
%   There are hundreds of lab measurements with imperfect labels.
%   I was looking for an easy way to rename all the files, so I
%   wrote this function.
%
%   src = '\\testlab\product_xyz\data\*test?*.s4p'
%   dest = \\testlab\product_xyz\data_renamed\*!bTest?*.s4p'
%   easycopy(src,dest);
%   DONE !
% 
% This scenario uses wildcards, plus the "!b" custom code.  More on that, later in EXAMPLES and in the ADVANCED USERS section. 
% 
% -------------------------------------------------------------------------
% EXAMPLES AND MOST COMMON USES OF EASYCOPY:
%
% sourcelist_fullpath = { 'c:\users\mjrowlands\desktop\NOTES.txt' 'c:\users\mjrowlands\desktop\.condarc' }; 
% destlist_fullpath = { 'c:\users\mjrowlands\desktop\n2.txt' 'c:\users\mjrowlands\desktop\condy.bat' };
% sourcelist_relative = { 'desktop\NOTES.txt'    'desktop\.condarc' };
% destlist_relative = { 'desktop\n2.txt'  'desktop\condy.bat' };
% source_basedir = 'c:\users\mjrowlands'; % for use with sourcelist_relative
% dest_basedir = 'c:\users\mjrowlands\desktop2'; % for use with destlist_relative
% Generally, a blank argument ('' or {} or []) gives the user the typical default settings.
% 
%  INPUT: easycopy                                  
% RESULT: displays these help instructions
%
%  INPUT: easycopy(sourcelist_fullpath,destlist_fullpath)
% RESULT: This is the most basic form of easycopy.
%         Takes the sourcelist and copies files 1:1 to the destlist.
%   Copying c:\users\mjrowlands\desktop\NOTES.txt
%   To c:\users\mjrowlands\desktop\n2.txt
%   Copying c:\users\mjrowlands\desktop\.condarc
%   To c:\users\mjrowlands\desktop\condy.bat
%
%  INPUT: easycopy(sourcelist_fullpath,'','',dest_basedir)
% RESULT: The blank argument uses the default settings for destlist (same filename as sourclist) and for
%         sourcebase. (ignored in this case because the sourcelist has the fullpath filename.)
%         This example copies all the files in sourcelist, to a new
%         directory tree.
%   Copying c:\users\mjrowlands\desktop\NOTES.txt
%   To c:\users\mjrowlands\desktop2\NOTES.txt
%   Copying c:\users\mjrowlands\desktop\.condarc
%   To c:\users\mjrowlands\desktop2\.condarc
%
%  INPUT: easycopy(sourcelist_relative,destlist_relative,source_basedir,dest_basedir)
% RESULT: This example builds the fullpath sourcelist from the source_basedir and the sourcelist_relative inuts.
%         The fullpath destlist is build from the dest_basedir and the destlist_relative inputs.
%         The fullpath deslist and sourcelist are then used to copy files 1:1 from each list.
%   Copying c:\users\mjrowlands\desktop\NOTES.txt
%   To c:\users\mjrowlands\desktop2\desktop\n2.txt
%   Copying c:\users\mjrowlands\desktop\.condarc
%   To c:\users\mjrowlands\desktop2\desktop\condy.bat
%
%  INPUT: easycopy('c:\users\mjrowlands\desktop\copyfile.csv')
% RESULT: With one argument, easycopy loads the file and reads the contents of that file.
%         It ignores the first row as a header row.
%         It loads column 1 as the source file list and
%         column 2 as the destination file list.
%         This is a powerful option with many useful scenarios, 
%         see ADVANCED USERS section for more details.
%   Copying c:\users\mjrowlands\desktop\NOTES.txt
%   To c:\users\mjrowlands\desktop2\NOTES2.txt
%   Copying c:\users\mjrowlands\desktop\.condarc
%   To c:\users\mjrowlands\desktop2\subdirectory\condy.bat
%
%  INPUT: easycopy('c:\users\mjrowlands\desktop\measuredata\*test?*.txt','*!bTest?_*.txt')
% RESULT: This finds the *test?_*.txt expression in the filenames.  Then it
%         replaces with Test?_ and moves that string to the beginning of
%         the filename.
% Copying c:\users\mjrowlands\desktop\measuredata\FEXT_test1_try2.txt
% To c:\users\mjrowlands\desktop\measuredata\Test1_FEXT__try2.txt
% Copying c:\users\mjrowlands\desktop\measuredata\IL_TEST3.txt
% To c:\users\mjrowlands\desktop\measuredata\Test3_IL_.txt
% Copying c:\users\mjrowlands\desktop\measuredata\NEXT_test2_crosstalk.txt
% To c:\users\mjrowlands\desktop\measuredata\Test2_NEXT__crosstalk.txt
%
%  INPUT: easycopy('desktop\a*.txt','pi\3p14\b*.txt2','c:\users\mjrowlands\','c:\users\mjrowlands\desktop\42\')
% RESULT: This builds the search directory with the base directory 'c:\users\mjrowlands\' plus the relative path 'desktop\a*.txt'.
%         Then builds the destination directory with the base directory 'c:\users\mjrowlands\desktop\42\' plus the relative path
%         'pi\3p14\b*.t'.  If finds the a*.txt filenames and copies to the destination and changes to a b*.txt2 filename.
%         The tool also searches through subdirectories to find a*.txt files and copies those subdirectories to the destination.
% Copying c:\users\mjrowlands\desktop\files\port\AkelPadPortable\App\AkelPadx64\AkelFiles\Docs\AkelHistory-Rus.txt
% To c:\users\mjrowlands\desktop\42\pi\3p14\files\port\AkelPadPortable\App\AkelPadx64\AkelFiles\Docs\bkelHistory-Rus.txt2
% Copying c:\users\mjrowlands\desktop\files\port\PerlPortable\App\Perl\perl\lib\Unicode\Collate\allkeys.txt
% To c:\users\mjrowlands\desktop\42\pi\3p14\files\port\PerlPortable\App\Perl\perl\lib\Unicode\Collate\bllkeys.txt2
% Copying c:\users\mjrowlands\desktop\stkbkup\files\productivity\taxes\2013\amended_2013.txt
% c:\users\mjrowlands\desktop\42\pi\3p14\stkbkup\files\productivity\taxes\2013\bmended_2013.txt2
%
%  INPUT: easycopy('c:\users\mjrowlands\desktop\f*.txt','c:\users\mjrowlands\desktop\42\!ez*.bat')
% RESULT: This finds 'f*.txt' files in any directory or subdirectory from
%         the source directory.  The destination file has the dest
%         directory, plus the source subdirectory, plus it has the !e code.
%         So the 'z' string in the destination file, is always moved to the
%         end of the filename.  Read the filenames below carefully to
%         understand what !e does.
% Copying c:\users\mjrowlands\desktop\IFT\MlxToolsExamples\MeasuredData1\files2cascade.txt
% To c:\users\mjrowlands\desktop\42\IFT\MlxToolsExamples\MeasuredData1\iles2cascadez.bat
% Copying c:\users\mjrowlands\desktop\measuredata\FEXT_test1_try2.txt
% To c:\users\mjrowlands\desktop\42\measuredata\EXT_test1_try2z.bat
% Copying c:\users\mjrowlands\desktop\MlxToolsExamples\files2cascade.txt
% To c:\users\mjrowlands\desktop\42\MlxToolsExamples\iles2cascadez.bat
%
% -------------------------------------------------------------------------
% RULES:
% > The directory matching is always case-insensitive.
% > Default filename matching is case-insensitive. See ADVANCED USERS section for other options.
% > Default find-replace match is case-insensitive.  See ADVANCED USERS section for other options.
% > "source" and "dest" are either:
%   fullpath ->  starts with \\, \ or <drive letter>:
%   relative ->  starts with text and use the sourcebase and destination base directories
%   example:  absolute = 'c:\users\username\desktop\
% > If dest is blank {} or '', then it just copies the source filename and uses the destdir directory
%   [sourcedir] = optional argument for source directory, otherwise it starts at the current directory
%   Use a blank [] or {} or '' to skip the sourcedir argument and enter a destdir.
% > Generally, the easycopy function tries to do the right thing and read the user's mind, depening on the different argument types and
%   different numbers of arguments.
% > A file cannot be copied onto itself.  If the easycopy command asks for
%   that, it will stop and copies no files, and return an error message.
% > Read ERROR messages carefully for more rules and explanations for why
%   the easycopy command doesn't work in a particular configuration.
%   Thanks to Y. Altman for the elegant cprintf function.
%
%***************** ADVANCED USERS: ****************************
% Wildcard Rules:
% The * and ? wildcards are supported in the source and dest file lists and behave as the basic windows wildcards.
%    * = match anything,  ? = match any one character
% If the source has wildcards, then the dest must be blank, or a single
% entry, or contain the same wildcards, or must match the length of the list of found files in the
% wildcard
% A user may match a source list of one entry, with a wildcard, with a
% multi-entry dest list, with no wildcards, if the dest list length has
% exactly the same number of entries that the source list matches.
%
% The source and dest must have the same number of each type of wildcard.
% For instance if source is 'c:\users\mjrowlands\desktop\a*abc?*.txt' then
% dest must have exactly two * and one ?.
% The dest argument also supports !b and !e which force the matching wildcards to the
% beginning of the destination string (See the story at the beginning of the help text, to see why this feature is useful)
%
% If there's one argument, the contents of the file will be read and each row of the
% file will be run as an easycopy command.
% Then the exact source and destination file lists from the columns of
% the file, with the first row ignored as a header.  Supported formats are .txt,.csv and .xlsx
%     .txt is read as tab-delimited text
%     .csv is read as comma delimited
%     .xlsx is read as standard excel format
% 
% CASE-SENSITIVITY AND MATCHING 
% By default, the source file match is case-insensitive and 
% the find-replace function is case-insensitive.
% 5th and 6th arguments specify this feature.
% (Again, use blank arguments to skip the 3rd and 4th arguments.)
% The 5th arg is the find setting: 
%      'sensitive' or 'insensitive'
% The 6th arg is the replace setting. (See regexprep function for more details.)
%      'ignore' or '' = default, case insensitive find-replace
%      'preserve' = preservecase
%  > easycopy('c;\users\mjrowlands\desktop\a*.txt','c;\users\mjrowlands\desktop\B*.txt','','','','sensitive','ignore');
%       > matches a...txt (not A...txt) // replaces with B.....txt
%  > easycopy('c;\users\mjrowlands\desktop\a*.txt','c;\users\mjrowlands\desktop\B*.txt','','','','insensitive','preserve');
%       > matches a...txt and A...txt) // replaces with b....txt and B.....txt respectively
%
% EXAMPLE file read:  (copylist.csv)
% 
% SOURCE FILE LIST,  DESTINATION FILE LIST
% c:\users\mjrowlands\desktop\.condarc,c:\users\mjrowlands\desktop\testyfile\test.bat
% c:\users\mjrowlands\desktop\notes.txt,c:\users\mjrowlands\desktop\testyfile\n2.txt
% 
% Note that the read file option is line-by-line, each line can have
% wildcards.  This makes batch runs of multiple commands easy.
% 
% Simple example:
%  INPUT: easycopy('c:\users\mjrowlands\desktop\v*.txt','','','c:\users\mjrowlands\desktop\copy2\')
% RESULT: Copy all files v*.txt (including subdirectories) to the base directory ...desktop\copy2\
%         Note that the destination directory copies the subdirectory path and adds it to the base direcotry.
%   Copying c:\users\mjrowlands\desktop\files\port\AudacityPortable\App\VSTPlugins\vstplugins_readme.txt
%   To c:\users\mjrowlands\desktop\copy2\files\port\AudacityPortable\App\VSTPlugins\vstplugins_readme.txt
%
%-------------------------------------------------------------------------
% QUESTIONS, COMMENTS, FEEDBACK
% Michael Rowlands - v1.4 2017-07-11
% Engineering in the 21st century; Make It Easy !
% easineering@gmail.com
%-------------------------------------------------------------------------

filecode = '';
replacecode = 'ignorecase';

if nargin < 1
    help easycopy
    return
end

if nargin == 1
    readfile = varargin{1};
    cprintf('*text','%s\n',['LOADING FILE ',readfile]);
    disp('Ignoring first row as header labels.')
    [num txt dat] = xlsread(readfile);
    [a b c] = size(txt);
    if b < 2
        cprintf('*red','%s\n','File must have at least 2 columns; one for source, one for destination.')
        return
    end
    sbase = '';
    dbase = '';
    filecode = '';
    replacecode = 'ignorecase';
    for i = 2:a
        slist = txt{i,1};
        dlist = txt{i,2};
        if b > 2
            sbase = txt{i,3};
        end
        if b > 3
            sbase = txt{i,4};
        end
        if b > 4
            filecode = txt{i,5};
        end
        if b > 5
            replacecode = txt{i,6};
        end
        easycopy(slist,dlist,sbase,dbase,filecode,replacecode);
    end
end 

if nargin == 1
    return
end

source = varargin{1};
dest = varargin{2};

sbasedef = 1;
dbasedef = 1;

if strcmpi(class(source),'cell') % array
    slen = length(source);
else  % it's a string, change to a one-entry array
    if strcmpi(class(source),'char')
        src1 = source;
        clear source;
        source{1} = src1;
        slen = length(source);
    else
        disp('ERROR: Format of source file list is not known.')
        dataout = [];
        return
    end
end 

if strcmpi(class(dest),'cell') % array
    dlen = length(dest);
else  % it's a string, change to a one-entry array
    if strcmpi(class(dest),'char')
        dest1 = dest;
        clear dest;
        dest{1} = dest1;
        if length(dest{1}) > 0
            dlen = length(dest);
        else
            dlen = 0;
        end
    else
        disp('ERROR: Format of destination file list is not known.')
        dataout = [];
        return
    end
end

if nargin > 2
    sourcebase = varargin{3};
    if strcmpi(class(sourcebase),'cell')
        if length(sourcebase)>1
            disp('ERROR: List of directories is not allowed, please use a single entry.')
            dataout = [];
            return
        else
            src1 = sourcebase{1};
            clear sourcebase
            sourcebase = src1;
        end
    end
    if length(sourcebase)>0
        if strcmp(sourcebase(1),'\') | strcmp(sourcebase(2:3),':\') | strcmp(sourcebase(1),'/')
            if not(strcmp(sourcebase(end),'\'))
%                sourcebase = sourcebase(1:(end-1));
                sourcebase = [sourcebase,'\'];
            end
        else
            'ERROR: Sourcedir must be an absolute path, start with \\ or \ or / or <drive>:\'
            dataout = [];
            return
        end
    else
        sourcebase = [pwd,'\'];
    end
else
    sourcebase = [pwd,'\'];
    sbasedef = 0;
end

if nargin > 3
    destbase = varargin{4};
    if strcmpi(class(destbase),'cell')
        if length(destbase)>1
            disp('ERROR: List of directories is not allowed, please use a single entry.')
            dataout = [];
            return
        else
            dest1 = destbase{1};
            clear destbase
            destbase = dest1;
        end
    end
    if length(destbase)>0
        if strcmp(destbase(1),'\') | strcmp(destbase(2:3),':\') | strcmp(destbase(1),'/')
            if not(strcmp(destbase(end),'\'))
%                destbase = destbase(1:(end-1));
                destbase = [destbase,'\'];
            end
        else
            disp('ERROR: Destdir must be an absolute path, start with \\ or \ or / or <drive>:\')
            dataout = [];
            return
        end
    else
        destbase = '';
    end
else
    destbase = '';
    dbasedef = 0;
end

if nargin > 4
    filecode = varargin{5};
    switch filecode
        case ''
            filecode = 1;
        case 'sensitive'
            filecode = 0;
        case 'insensitive'
            filecode = 1;
        case 'sensitivenosubdir'
            filecode = 2;
        case 'insensitivenosubdir'
            filecode = 3;
        otherwise
            cprintf([1,0.5,0], 'WARNING: Unable to understand the file case-sensitivity input.  Defaulting to case-insensitive.\n')
            filecode = 1;
    end
end

if nargin > 5
    replacecode = varargin{6};
    switch replacecode
        case ''
            replacecode = 'ignorecase';
        case 'ignorecase'
            replacecode = 'ignorecase';
        case 'ignore'
            replacecode = 'ignorecase';
        case 'preserve'
            replacecode = 'preservecase';
        case 'sensitive'
            replacecode = 'sensitive';             
        otherwise
            cprintf([1,0.5,0], 'WARNING: Unable to understand the replace case-sensitivity input.  Defaulting to case-insensitive.\n')
            replacecode = 'ignorecase';          
    end
end

d1 = dest{1};
if strcmp(d1(end),'\') | strcmp(d1(end),'/')
    destbase = dest{1};
    dest{1}='';
end

[srclisty destfullpath error] = buildlist(source,dest,sourcebase,destbase,filecode,replacecode); 
% function to buld the destlist, wildcards, !e !b ... etc
if error
    disp('ERROR creating file lists.')
    return
end
%disp('COPYING FILES .....');
fprintf('\n');
for i = 1:length(srclisty)
%     disp(['Copying ',srclisty{i}]);
%     disp(['To ',destfullpath{i}]);
%     fprintf('\n');
    [destydir,junk1,junk2]=fileparts(destfullpath{i});
    dirchk = dir(destydir);
    if length(dirchk)== 0  % directory doesn't exist
        try
            mkdir(destydir);% make the directory
        catch me
            cprintf('red','%s\n','ERROR: Cannot make directory.')
            cprintf('red','%s\n','Check the destination list, especially a leading slash when a relative path is intended.')
            cprintf('red','%s\n','For instance: easycopy(...,\desktop\*.tt2,...) gives an error.  The user probably meant easycopy(...,destkop\*.tt2,...)')
            return
        end
    end
    copyfile(srclisty{i},destfullpath{i});
end
if length(srclisty)==0
    disp('No files found.');
end    
%disp('DONE !');

