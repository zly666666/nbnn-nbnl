
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


function acc = adaptation_nomem(S,te,yte)

toadd=[];
remove=[];
uy=unique(S.label);

% gamma = 1 - 0.1*(number_of_iterations)
% here we consider only the initialization (number of iteration = 0)
% and the first iteration (number of iteration = 1)
gamma=[1 0.9]; %[1 0.9];
idxS=1:numel(S.label); %%al source image indexes

for j=1:numel(gamma)
    
    idxS(remove)=[]; %%remove source samples according to criterion
    
    ST.feat=S.feat(idxS);
    ST.label=S.label(idxS);
    
    Ns=numel(idxS);
    Nt=numel(toadd);
    %fprintf('Number of images in S: %d\n', Ns);
    %fprintf('Number of images in T: %d\n', Nt);   

    if Nt>0
        for h=1:Nt
            ST.feat{Ns+h}=te{toadd(h)};
        end
        ST.label(Ns+1:Ns+Nt)=pred_labels{j-1}(toadd);
    end
    
    fprintf('\nCalculate distances...\n');
    %[DD,delta,deltate]=fn_create_dist(ST,te);
    fprintf('Distance calculated\n');
    if j>1
        M=fn_create_metric_on_the_fly(ST, gamma(j),Ns); 
    else
        for c=uy
            M{c}=eye(size(te{1},1),size(te{1},1)); %feature descritor X feature descriptor
        end
    end

    for c=uy

        K=1;
        fprintf('Testing NBNN on class %d, with K=%d...\n',c,1);

        for z=1:Ns
            delta = getDeltaTrain(ST,z,c);
              DS(z,c)=trace(delta*M{c}*delta'); %computes distances from classes
        end
        
        for z=1:numel(yte)
            if ismember(toadd,z)
                [~,pos]=find(toadd==z);
                delta = getDeltaTrain(ST,Ns+pos,c);
                DT(z,c)=trace(delta*M{c}*delta');
                clear pos
            else
                deltate = getDeltaTest( ST, te,z,c);
                DT(z,c)=trace(deltate*M{c}*deltate');
            end
            clear vec feat_te ii                   
        end
    end
   
    [~, pred_labels{j}]=min(DT,[],2);
    accuracy(j)=sum(pred_labels{j}==yte')/numel(yte')*100;
    
    if j==1
        fprintf('\nstep %d, NBNN rec. rate: %.2f %%\n', j, accuracy(j));
    else
        fprintf('\nstep %d, DA-NBNN rec. rate: %.2f %%\n', j, accuracy(j));
    end
    
    % if the label of a target sample added to the source changes between
    % two subsequent iterations, the samples is moved back to the target
    % test set. 
    if j>1
        list=find(pred_labels{j}(toadd)~=pred_labels{j-1}(toadd));    
        toadd(list)=[];
    end
    clear list

    td=add(DT, toadd, pred_labels{j});
    toadd=[toadd td];
    clear td
    
    [vals,ll]=sort(DS,2); 
    ics=vals(:,2)-vals(:,1);
    li=find(ics<1);
    ics(li)=-Inf;
    [~,choose]=sort(ics,'descend');
    clear ics li val ll
    
    remove=[];
    for c=uy
        idx=find(S.label(choose)==c);
        sel=min(numel(idx),2);
        remove=[remove choose(idx(1:sel))'];
        clear idx sel
    end
    clear DT DS
    clear ST
end
acc=accuracy(end);
