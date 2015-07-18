function o = ObjUpdate (o)
%
global BAPHYHOME
if isempty(BAPHYHOME)
    baphy_set_path;
end
    
DatasetNum = get(o,'DatasetNum');
soundpath = [BAPHYHOME filesep 'SoundObjects' filesep '@MusicPieces' filesep 'MusicPiecesDataset' filesep sprintf('dataset%03s',num2str(DatasetNum))];

temp = dir([soundpath filesep '*.wav']);
Names = cell(1,length(temp));
[Names{:}] = deal(temp.name);
o = set(o,'Names',Names);
o = set(o,'SoundPath',soundpath);
o = set(o,'MaxIndex', length(Names));
