
% This code is part of the supplementary material to the ICCV 2013 paper
% "Frustratingly Easy NBNN Domain Adaptation", T. Tommasi, B. Caputo. 
%
% Copyright (C) 2013, Tatiana Tommasi
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Please cite:
% @inproceedings{TommasiICCV2013,
% author = {Tatiana Tommasi, Barbara Caputo},
% title = {Frustratingly Easy NBNN Domain Adaptation},
% booktitle = {ICCV},
% year = {2013}
% }
%
% Contact the author: ttommasi [at] esat.kuleuven.be
%


function toadd = add(dec,oldadd,label)

    [val,~]=sort(dec,2);
    diff=1-val(:,2)+val(:,1);
    diff(oldadd)=Inf;
    clear val
    list=find(diff<0);
    diff(list)=Inf;
    [~,extract]=sort(diff);

    uy=unique(label');
    toadd=[];
    for c=uy
        idx=find(label(extract)==c);
        sel=min(numel(idx),2);
        toadd=[toadd extract(idx(1:sel))'];
        clear sel idx
    end

end
