clc,clear,close all
%% Truss No.
FN = 'DATA_pont_1m_Num4';
%% Options personalisées d'analyse

% Affiche dans la console le numéro de la liaison, la contrainte subie et,
% la contraite max des nb_spaghetto_compression_max_to_print spaghetti 
% dont la contraite en compression est la plus proche de la contrainte 
% critique. Si on ne veut rien afficher, mettre cette variable à 0.
nb_spaghetto_compression_max_to_print = 0; 

% On multiplie la force de chargement de chaque point par ce coefficient.
% Ca permet de trouver la valeur max théorique de chargement, en effectuant
% plusieurs analyses avec des valeurs différentes de facteur. Si ce facteur
% vaut 1, le chargement renseigné sur la feuille de calculs est inchangé.
facteur_chargement_initial = 0.60;

% A chaque itération, on multiplie facteur_chargement_initial par 
% coef_augmente_facteur_chargement tant que le pont ne casse pas. Ce coef
% doit donc être supérieur à 1.
coef_augmente_facteur_chargement = 1;

% Nombre d'essais max qu'on effectue pour essaier de faire casser le pont,
% sachant qu'on augmente à chaque fois le facteur de chargement pas 
% coef_augmente_facteur_chargement. Bien faire attention à ne pas afficher 
% les graphiques dans le fichier PlotResults.
nb_essais_max = 1;

% Prendre en compte l'incertitude de position des noeuds due à la
% construction manuelle du pont
ecart_type = 0.000; % En mètres
deplacement_max = 0.005; % En mètres. Permet de borner les variations  de la position des noeuds pour toujours avoir qqchose de réaliste

% Prendre en compte l'incertitude de position des noeuds due à la
% construction manuelle du pont
ecart_type_E = 0; % En Pa
variation_E_max = 240000000; % En Pa. Permet de borner les variations  du module d'Young des spaghetti pour toujours avoir qqchose de réaliste


% Nombre d'expériences que la simulation va faire à la suite. A utiliser en
% parallèle avec un écart type non nul. Bien faire attention à ne pas
% afficher les graphiques dans le fichier PlotResults.
nb_experiences = 1;


facteur_charge_max_moyen = 0;
for num_experience=1:nb_experiences
    nb_ponts_casses = 0;
    disp(" ")
    disp("...........")
    disp("Essai de pont numéro " + num_experience)
    disp("...........")
    %% Input Data
    TrussData = readmatrix([FN '.xlsx'], 'Sheet', 1);
    JointNo=TrussData(:,1);
    
    xJoint=TrussData(:,2);
    xJoint = xJoint + max(min(randn(length(xJoint), 1).*ecart_type, deplacement_max), -deplacement_max);
    
    yJoint=TrussData(:,3);       
    yJoint = yJoint + max(min(randn(length(yJoint), 1).*ecart_type, deplacement_max), -deplacement_max);
    
    zJoint=TrussData(:,4); 
    zJoint = zJoint + max(min(randn(length(zJoint), 1).*ecart_type, deplacement_max), -deplacement_max);
    
    XR=TrussData(:,5);
    YR=TrussData(:,6);
    ZR=TrussData(:,7);
    FX=TrussData(:,8);                    
    FY=TrussData(:,9);                  
    FZ=TrussData(:,10);                   
    ElementNo=TrussData(:,11);
    contraintes_critiques = zeros(length(ElementNo));
    BJ=TrussData(:,12);
    EJ=TrussData(:,13);
    E=TrussData(:,14);                    
    E = E + max(min(randn(length(E), 1).*ecart_type_E, variation_E_max), -variation_E_max);
    A=TrussData(:,15);                   
    [JointNo,ElementNo,xJoint,yJoint,XR,YR,FX,BJ,EJ,E,A,FY,zJoint,ZR,FZ]=...,
        RemovedNan(JointNo,ElementNo,xJoint,yJoint,XR,YR,FX,BJ,EJ,E,A,FY,zJoint,ZR,FZ); %% Removed NaN cell
    NJ=max(JointNo);                    %Number of joint 
    NElement=max(ElementNo);   %Number of element  
    gcords=[xJoint,yJoint,zJoint];
    SC=200;%magnifier for undeformd shape
    nodeselements=[BJ,EJ];
    support=[XR YR ZR];
    %% Figures 
    disp_Shape='on';
    disp_Reactions='on';
    disp_Deformed='on';
    disp_Stress='on';
    disp_OPT={disp_Shape;disp_Reactions;disp_Deformed;disp_Stress};
    %% Calculate the length of each element and Calculate Cos 
    L=zeros(1,NElement);
    cx=zeros(1,NElement);
    cy=zeros(1,NElement);
    cz=zeros(1,NElement);
    for i=1:NElement
    L(i)=sqrt(((xJoint(EJ(i))-(xJoint(BJ(i))))^2)+((yJoint(EJ(i))-(yJoint(BJ(i))))^2)+((zJoint(EJ(i))-(zJoint(BJ(i))))^2));%length of element  
    cx(1,i)=((xJoint(EJ(i)))-(xJoint(BJ(i))))/L(i);  
    cy(1,i)=((yJoint(EJ(i)))-(yJoint(BJ(i))))/L(i);
    cz(1,i)=((zJoint(EJ(i)))-(zJoint(BJ(i))))/L(i);
    end
    
    %% Create K Matrix
    KMatrix=zeros(3*NJ);
    for i=1:NElement
    kk=E(i)* A(i) /L(i);
    %%% 1 column
    KMatrix(3*BJ(i)-2,3*BJ(i)-2)=KMatrix(3*BJ(i)-2,3*BJ(i)-2)+ kk.*cx(i)^2;   %%(3i-2 and 3i-2)
    KMatrix(3*BJ(i)-2,3*BJ(i)-1)=KMatrix(3*BJ(i)-2,3*BJ(i)-1)+kk*cx(i)*cy(i);  %%(3i-2 and 3i-1)
    KMatrix(3*BJ(i)-2,3*BJ(i))=KMatrix(3*BJ(i)-2,3*BJ(i))+kk*cx(i)*cz(i);        %%(3i-2 and 3i)
    KMatrix(3*BJ(i)-2,3*EJ(i)-2)=KMatrix(3*BJ(i)-2,3*EJ(i)-2)- kk.*cx(i)^2;     %%(3i-2 and 3j-2)
    KMatrix(3*BJ(i)-2,3*EJ(i)-1)=KMatrix(3*BJ(i)-2,3*EJ(i)-1)-kk*cx(i)*cy(i);    %%(3i-2 and 3j-1)
    KMatrix(3*BJ(i)-2,3*EJ(i))=KMatrix(3*BJ(i)-2,3*EJ(i))-kk*cx(i)*cz(i);           %%(3i-2 and 3j)
    %%% 2 column
    KMatrix(3*BJ(i)-1,3*BJ(i)-2)=KMatrix(3*BJ(i)-1,3*BJ(i)-2)+ kk.*cx(i)*cy(i);   %%(3i-1 and 3i-2)
    KMatrix(3*BJ(i)-1,3*BJ(i)-1)=KMatrix(3*BJ(i)-1,3*BJ(i)-1)+kk*cy(i)^2;  %%(3i-1 and 3i-1)
    KMatrix(3*BJ(i)-1,3*BJ(i))=KMatrix(3*BJ(i)-1,3*BJ(i))+kk*cy(i)*cz(i);        %%(3i-1 and 3i)
    KMatrix(3*BJ(i)-1,3*EJ(i)-2)=KMatrix(3*BJ(i)-1,3*EJ(i)-2)- kk.*cx(i)*cy(i);      %%(3i-1 and 3j-2)
    KMatrix(3*BJ(i)-1,3*EJ(i)-1)=KMatrix(3*BJ(i)-1,3*EJ(i)-1)-kk*cy(i)^2;   %%(3i-1 and 3j-1)
    KMatrix(3*BJ(i)-1,3*EJ(i))=KMatrix(3*BJ(i)-1,3*EJ(i))-kk*cy(i)*cz(i);         %%(3i-1 and 3j)
    %%% 3 column
    KMatrix(3*BJ(i),3*BJ(i)-2)=KMatrix(3*BJ(i),3*BJ(i)-2)+ kk.*cx(i)*cz(i);   %%(3i and 3i-2)
    KMatrix(3*BJ(i),3*BJ(i)-1)=KMatrix(3*BJ(i),3*BJ(i)-1)+kk*cy(i)*cz(i);  %%(3i and 3i-1)
    KMatrix(3*BJ(i),3*BJ(i))=KMatrix(3*BJ(i),3*BJ(i))+kk*cz(i)^2;        %%(3i and 3i)
    KMatrix(3*BJ(i),3*EJ(i)-2)=KMatrix(3*BJ(i),3*EJ(i)-2)- kk.*cx(i)*cz(i);      %%(3i and 3j-2)
    KMatrix(3*BJ(i),3*EJ(i)-1)=KMatrix(3*BJ(i),3*EJ(i)-1)-kk*cy(i)*cz(i);   %%(3i and 3j-1)
    KMatrix(3*BJ(i),3*EJ(i))=KMatrix(3*BJ(i),3*EJ(i))-kk*cz(i)^2;          %%(3i and 3j)
    %%% 4 column
    KMatrix(3*EJ(i)-2,3*BJ(i)-2)=KMatrix(3*EJ(i)-2,3*BJ(i)-2)- kk.*cx(i)^2;   %%(3j-2 and 3i-2)
    KMatrix(3*EJ(i)-2,3*BJ(i)-1)=KMatrix(3*EJ(i)-2,3*BJ(i)-1)-kk*cx(i)*cy(i);  %%(3j-2 and 3i-1)
    KMatrix(3*EJ(i)-2,3*BJ(i))=KMatrix(3*EJ(i)-2,3*BJ(i))-kk*cx(i)*cz(i);        %%(3j-2 and 3i)
    KMatrix(3*EJ(i)-2,3*EJ(i)-2)=KMatrix(3*EJ(i)-2,3*EJ(i)-2)+ kk.*cx(i)^2;     %%(3j-2 and 3j-2)
    KMatrix(3*EJ(i)-2,3*EJ(i)-1)=KMatrix(3*EJ(i)-2,3*EJ(i)-1)+kk*cx(i)*cy(i);    %%(3j-2 and 3j-1)
    KMatrix(3*EJ(i)-2,3*EJ(i))=KMatrix(3*EJ(i)-2,3*EJ(i))+kk*cx(i)*cz(i);           %%(3j-2 and 3j)
    %%% 5 column
    KMatrix(3*EJ(i)-1,3*BJ(i)-2)=KMatrix(3*EJ(i)-1,3*BJ(i)-2)- kk.*cx(i)*cy(i);   %%(3j-1 and 3i-2)
    KMatrix(3*EJ(i)-1,3*BJ(i)-1)=KMatrix(3*EJ(i)-1,3*BJ(i)-1)-kk*cy(i)^2;  %%(3j-1 and 3i-1)
    KMatrix(3*EJ(i)-1,3*BJ(i))=KMatrix(3*EJ(i)-1,3*BJ(i))-kk*cy(i)*cz(i);        %%(3j-1 and 3i)
    KMatrix(3*EJ(i)-1,3*EJ(i)-2)=KMatrix(3*EJ(i)-1,3*EJ(i)-2)+kk.*cx(i)*cy(i);      %%(3j-1 and 3j-2)
    KMatrix(3*EJ(i)-1,3*EJ(i)-1)=KMatrix(3*EJ(i)-1,3*EJ(i)-1)+kk*cy(i)^2;   %%(3j-1 and 3j-1)
    KMatrix(3*EJ(i)-1,3*EJ(i))=KMatrix(3*EJ(i)-1,3*EJ(i))+kk*cy(i)*cz(i);         %%(3j-1 and 3j)
    %%% 6 column
    KMatrix(3*EJ(i),3*BJ(i)-2)=KMatrix(3*EJ(i),3*BJ(i)-2)- kk.*cx(i)*cz(i);   %%(3j and 3i-2)
    KMatrix(3*EJ(i),3*BJ(i)-1)=KMatrix(3*EJ(i),3*BJ(i)-1)-kk*cy(i)*cz(i);     %%(3j and 3i-1)
    KMatrix(3*EJ(i),3*BJ(i))=KMatrix(3*EJ(i),3*BJ(i))-kk*cz(i)^2;               %%(3j and 3i)
    KMatrix(3*EJ(i),3*EJ(i)-2)=KMatrix(3*EJ(i),3*EJ(i)-2)+ kk.*cx(i)*cz(i);   %%(3j and 3j-2)
    KMatrix(3*EJ(i),3*EJ(i)-1)=KMatrix(3*EJ(i),3*EJ(i)-1)+kk*cy(i)*cz(i);     %%(3j and 3j-1)
    KMatrix(3*EJ(i),3*EJ(i))=KMatrix(3*EJ(i),3*EJ(i))+kk*cz(i)^2;                %%(3j and 3j)
    end
    
    
    va_casser = false;
    nb_iter = 1;
    facteur_chargement = facteur_chargement_initial;
    while ~va_casser & nb_iter <= nb_essais_max 
        %% Create load vector
        load=zeros(3*NJ,1);
        for i=1:NJ
                if FX(i)~=0
                    load(3*i-2,1)=facteur_chargement*FX(i);
                end
                if FY(i)~=0
                    load(3*i-1,1)=facteur_chargement*FY(i);
                end
                if FZ(i)~=0
                    load(3*i,1)=facteur_chargement*FZ(i);
                end
        end
           
        %% Finding the Displacement for each joint
        BigNumber=2e15;
        KMatrix2=KMatrix;
        for i=1:NJ
            if  XR(i)==1
                KMatrix2(3*i-2,3*i-2)=KMatrix(3*i-2,3*i-2)+BigNumber;
            end
            if  YR(i)==1
                KMatrix2(3*i-1,3*i-1)=KMatrix(3*i-1,3*i-1)+BigNumber;
            end
            if  ZR(i)==1
                KMatrix2(3*i,3*i)=KMatrix(3*i,3*i)+BigNumber;
            end
        end
        Disp=KMatrix2\load;
        JointDisp=zeros(3*NJ,1);
        for i=1:3*NJ
            if abs(Disp(i,1))<1e-10
                JointDisp(i,1)=0;
            else 
                JointDisp(i,1)=Disp(i,1);
            end
        end
        
        for i=1:NJ
            X_JD(i,1)=(JointDisp(3*i-2));
            Y_JD(i,1)=(JointDisp(3*i-1));
            Z_JD(i,1)=(JointDisp(3*i));
        end
            X_JD;Y_JD;Z_JD;
           W=[X_JD  Y_JD Z_JD];
        %% Finding Stress in Each element and Support reactions
        Stress=zeros(NElement,1);
        for i=1:NElement
            Stress(i,1)=(E(i)/L(i))*(-cx(i)*JointDisp(3*BJ(i)-2)-cy(i)*JointDisp(3*BJ(i)-1)-cz(i)*JointDisp(3*BJ(i))+cx(i)*JointDisp(3*EJ(i)-2)+cy(i)*JointDisp(3*EJ(i)-1)+cz(i)*JointDisp(3*EJ(i)));
        end
        
        R=KMatrix*JointDisp;%Support reactions
        for i=1:3*NJ
            if abs(R(i,1))<1e-5
                R(i,1)=0;
            else
                R(i,1)=R(i,1);
            end
        end
        
        %% Write Microsoft Excel spreadsheet result
        filename = ['Results3D ' FN datestr(now,' HH-MM ') '.xlsx'];
    
        writematrix(load, filename, 'Sheet', 1, 'Range', 'A2');
        writematrix(JointDisp, filename, 'Sheet', 1, 'Range', 'B2');
        writematrix(Stress, filename, 'Sheet', 1, 'Range', 'C2');
        writematrix(R, filename, 'Sheet', 1, 'Range', 'D2');
        %% Truss Shape
        PlotResults(ElementNo,A,JointNo,BJ,EJ,xJoint,yJoint,zJoint,E,NElement,gcords,nodeselements,NJ,W,load,R,Stress,support,SC,disp_OPT)
        
        %% Détermine si au moins une des barres subit une compression supérieure 
        % à la contrainte critique
        sigma = Stress(:);
        va_casser = false;
        for i = 1:length(sigma)
            if sigma(i) < 0  % On est dans le cas d'une compression
                rayon = sqrt(A(i)/pi);
                diametre = 2*rayon;
                longueur = sqrt((xJoint(find(JointNo == BJ(i), 1)) - xJoint(find(JointNo == EJ(i), 1)))^2 ...
                    + (yJoint(find(JointNo == BJ(i), 1)) - yJoint(find(JointNo == EJ(i), 1)))^2 ...
                    + (zJoint(find(JointNo == BJ(i), 1)) - zJoint(find(JointNo == EJ(i), 1)))^2);
                force_critique = pi^3*E(i)*diametre^4/(64*longueur^2);
                contrainte_critique = force_critique/A(i);
                contraintes_critiques(i) = contrainte_critique;
                if contrainte_critique < abs(sigma(i))
                    va_casser = true;
                    disp("Un spaghetto a subi une contrainte en compression supérieure à la contrainte critique")
                    disp("contrainte critique de compression (en valeur absolue) :" + contrainte_critique)
                    disp("contrainte subie (en valeur absolue) :" + abs(sigma(i)))
                    disp("Numéro de la liaison :" + ElementNo(i))
                end
            end
        end
        
        %% Affiche les spaghetti soumis à la contrainte en compression la plus grande
        if nb_spaghetto_compression_max_to_print > 0
            sigma = Stress(:);
            
            rapport_sigma = sigma ./ contraintes_critiques;
            [rapport_sigma_sorted, sort_idx] = sort(rapport_sigma); % On trie les spaghettis en fonction de leur rapport contrainte en compression subie / contrainte critique
            elements_sorted = ElementNo(sort_idx); 
            contraintes_critiques_sorted = contraintes_critiques(sort_idx);
            sigma_sorted = sigma(sort_idx);
            disp('---');
            disp('Liaisons dont la contrainte de compression subie est le plus proche de la contrainte critique (en terme de rapport) :');
            for i = 1:nb_spaghetto_compression_max_to_print
                disp(">>> Liaison " + elements_sorted(i) + ", contrainte subie : " + sigma_sorted(i) + ", contrainte critique : " + contraintes_critiques_sorted(i))
            end
            disp('---');
        end

        if va_casser
            % Si au moins un des spaghettis va casser, on indique quel
            % intervalle de facteur de chargement a causé la rupture du pont
            disp("Le pont va casser pour un facteur de chargement " + ...
                "compris entre " + facteur_chargement/coef_augmente_facteur_chargement ...
                + " et " + facteur_chargement)
        else 
            % Si le pont n'a pas cassé, on recommence avec un facteur de
            % chargement plus élevé
            facteur_chargement = facteur_chargement*coef_augmente_facteur_chargement;

            if nb_iter == nb_essais_max
            disp("Il y a eu " + nb_iter + " itérations. A la fin le " + ...
                "facteur de chargement valait " + facteur_chargement + ...
                ". Mais le pont n'a jamais cassé.")
            end
        end

        nb_iter = nb_iter + 1;
    end
    facteur_charge_max_moyen = facteur_charge_max_moyen + ...
        facteur_chargement/coef_augmente_facteur_chargement;
end
facteur_charge_max_moyen = facteur_charge_max_moyen / nb_experiences;
disp("...")
disp("Facteur de charge max moyen que le pont peut supporter au " + ...
    "cours de " + nb_experiences + " expériences :")
disp(">>> " + facteur_charge_max_moyen)
disp("...")
%% finish