function  PlotResults(ElementNo, A, JointNo, BJ, EJ, xJoint, yJoint, zJoint, E, NElement,gcords,nodeselements,NJ,W,load,R,Stress,support,SC,disp_opt)

% Si on affiche le graphiques, il est téférables de bien vérifier dans le 
% fichier truss3D qu'on ne répète qu'une fois l'expérience
AFFICHE_GRAPHIQUES = true; 

% Affiche seulement le graphique des contraintes, pour que la graphique
% soit plus visible, et pour alléger les calculs numériques
AFFICHE_SEULEMENT_CONTRAINTE = true;

% Sur le graphique des contraintes, affiche le rapport 
% contrainte subie / contrainte réelle au lieu des valeurs brutes. Dans ce
% cas, il faut bien faire attention à mettre un facteur de chargement (dans
% le fichier truss3D) qui correspond au chargement maximal du pont
AFFICHE_RAPPORT_CONTRAINTE = true; 

% Affiche la valeur numérique des contraintes (que ce soit le rapport ou la
% valeur brute) sur chaque spaghetti du graphique des contraintes
AFFICHE_VALEUR_CONTRAINTE = true;

FORCE_TRACTION_CRITIQUE = 34; % Force de traction critique en Newton
%% Truss Shape
if AFFICHE_SEULEMENT_CONTRAINTE == false && AFFICHE_GRAPHIQUES == true
    if strcmp(disp_opt{1},'on') %%%Compare strings
        subplot(2,2,1);
        view(3)
        for j=1:NElement
            X=[gcords(nodeselements(j,:),1)];
            Y=[gcords(nodeselements(j,:),2)];
            Z=[gcords(nodeselements(j,:),3)];
            hold on
            plot3(X,Y,Z,'c','linewidth',2)
            plot3(X,Y,Z,'o','linewidth',2)
            grid on
            xlabel('X axis \rightarrow','Color','m')
            ylabel('Y axis \Rightarrow','Color','b')
            zlabel('Z axis \rightarrow','Color','g')
            title('Undeformed Shape')
        end
        for a=1:NJ
            nodes=(num2str(a));
            text(gcords(a,1),gcords(a,2),gcords(a,3),nodes,'Color',[0.95 0.35 0],'VerticalAlignment','bottom','HorizontalAlignment','center')
        end
        %%% support
        Support=sum(support,2);
        for a=1:NJ
            if Support(a)>2
                SUPPORT='\Delta';
            elseif Support(a)==2
                SUPPORT='O';
            elseif Support(a)==0
                SUPPORT= '.';
            end
    
            SUP={SUPPORT};
            text(gcords(a,1),gcords(a,2),gcords(a,3),SUP,'Color','red','VerticalAlignment','cap','HorizontalAlignment','center')
    
        end
        %%% load and Direction
        ll=reshape(load,3,NJ);
        for a=1:NJ
            X=gcords(a,:);
            lod=ll(:,a)';
            bar(a,:)=[X lod];
        end
        for a=1:NJ
            X=bar(a,1);
            Y=bar(a,2);
            Z=bar(a,3);
            lodet=bar(a,4:6);
            for loadn=1:3
                LOADE=lodet(loadn);
                str = {LOADE};
                if LOADE~=0
                    if loadn==1
                        text(X,Y,Z,str,'Color','m','VerticalAlignment','cap','HorizontalAlignment','left')
                    elseif loadn==2
                        text(X,Y,Z,str,'Color','b','VerticalAlignment','bottom','HorizontalAlignment','center')
                    elseif loadn==3
                        text(X,Y,Z,str,'Color','g','VerticalAlignment','top','HorizontalAlignment','right')
                    end
                end
            end
    
        end
        for b=1:NElement
            Xe=[gcords(nodeselements(b,:),1)];
            Ye=[gcords(nodeselements(b,:),2)];
            Ze=[gcords(nodeselements(b,:),3)];
            Xm=sum(Xe)/2;
            Ym=sum(Ye)/2;
            Zm=sum(Ze)/2;
            elementname=(num2str(b));
            text(Xm,Ym,Zm,elementname,'Color','k')
        end
    end
end
%% Reactions
if AFFICHE_SEULEMENT_CONTRAINTE == false && AFFICHE_GRAPHIQUES == true
    if strcmp(disp_opt{2},'on')
        subplot(2,2,2);
        view(3)
        for j=1:NElement
            X=[gcords(nodeselements(j,:),1)];
            Y=[gcords(nodeselements(j,:),2)];
            Z=[gcords(nodeselements(j,:),3)];
            hold on
            plot3(X,Y,Z,'c','linewidth',2)
            plot3(X,Y,Z,'o','linewidth',2)
    
            grid on
            xlabel('X axis \rightarrow','Color','m')
            ylabel('Y axis \Rightarrow','Color','b')
            zlabel('Z axis \rightarrow','Color','g')
            title('Reactions')
        end
    
        RR=reshape(R,3,NJ);
        for a=1:NJ
            X=gcords(a,:);
            lod=RR(:,a)';
            bar(a,:)=[X lod];
        end
        for a=1:NJ
            X=bar(a,1);
            Y=bar(a,2);
            Z=bar(a,3);
            lodet=bar(a,4:6);
            for loadn=1:3
                LOADE=lodet(loadn);
                %         jahat = arrow(X0, Y0, Z0,LODE,loadn);
                str = {LOADE};
                if LOADE~=0
                    if loadn==1
                        text(X,Y,Z,str,'Color','m','VerticalAlignment','cap','HorizontalAlignment','left')
                    elseif loadn==2
                        text(X,Y,Z,str,'Color','b','VerticalAlignment','bottom','HorizontalAlignment','center')
                    elseif loadn==3
                        text(X,Y,Z,str,'Color','g','VerticalAlignment','top','HorizontalAlignment','right')
                    end
                end
            end
    
        end
    
    end
end
%% Deformed Shape
if AFFICHE_SEULEMENT_CONTRAINTE == false && AFFICHE_GRAPHIQUES == true
    if strcmp(disp_opt{3},'on')
      subplot(2,2,3);
        view(3)
        for j=1:NElement
            X=[gcords(nodeselements(j,:),1)];
            Y=[gcords(nodeselements(j,:),2)];
            Z=[gcords(nodeselements(j,:),3)];
            hold on
            plot3(X,Y,Z,'g','linewidth',2)
            plot3(X,Y,Z,'o','linewidth',2)
    
            grid on
            xlabel('X axis \rightarrow','Color','m')
            ylabel('Y axis \Rightarrow','Color','b')
            zlabel('Z axis \rightarrow','Color','g')
            title('Deformed Shape')
        end
    
        N_gcords=gcords+(W*SC);
    
        for j=1:NElement
            XX=[N_gcords(nodeselements(j,:),1)];
            YY=[N_gcords(nodeselements(j,:),2)];
            ZZ=[N_gcords(nodeselements(j,:),3)];
            hold on
            plot3(XX,YY,ZZ,'b--','linewidth',2)
            plot3(XX,YY,ZZ,'o','linewidth',2)
    
        end
    end
end
%% Stress Plot (colormap based on stress magnitude + text on each bar)
if strcmp(disp_opt{4},'on')
    if AFFICHE_GRAPHIQUES
        if AFFICHE_SEULEMENT_CONTRAINTE == false
            subplot(2,2,4);
        end 
        view(3)
        grid on
        %axis equal
        xlabel('X axis \rightarrow','Color','m')
        ylabel('Y axis \Rightarrow','Color','b')
        zlabel('Z axis \rightarrow','Color','g')
        title('Stress Plot')
        
        % Récupération des contraintes
        sigma = Stress(:);    % vecteur colonne

        % Normalisation
        if AFFICHE_RAPPORT_CONTRAINTE
            contraintes_critiques = zeros(length(sigma),1);
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
                else
                    contraintes_critiques(i) = FORCE_TRACTION_CRITIQUE / A(i);
                end
            end

            new_sigma = zeros(length(sigma),1);
            for i = 1:length(sigma)
                if contraintes_critiques == 0
                    new_sigma(i) = 0;
                else
                    new_sigma(i) = sigma(i) / contraintes_critiques(i);
                end
            end
        else
            new_sigma = sigma;
        end
        
        % Détection min/max
        smin = min(new_sigma);
        smax = max(new_sigma);
        
        if smax > smin
            if AFFICHE_RAPPORT_CONTRAINTE
                sigma_norm = (new_sigma - smin) ./ 2;
            else
                sigma_norm = (new_sigma - smin) ./ (smax - smin);
            end
        else
           sigma_norm = zeros(size(new_sigma));
        end

        % Colormap continue
        cmap = jet(256);
        
        % Tracé des barres
        for k = 1:length(new_sigma)
           % Coordonnées des noeuds extrémités
           X = gcords(nodeselements(k,:), 1);
           Y = gcords(nodeselements(k,:), 2);
           Z = gcords(nodeselements(k,:), 3);
        
           % Couleur selon contrainte
           idx = round(sigma_norm(k) * 255) + 1;
           idx = min(max(idx, 1), 256);
           color_k = cmap(idx, :);
        
           % Tracé de la barre
           line([X(1) X(2)], ...
                [Y(1) Y(2)], ...
                [Z(1) Z(2)], ...
                'Color', color_k, ...
                'Marker', '.', ...
                'MarkerSize', 15, ...
                'LineWidth', 2);
        
           % Ajout du texte au milieu de la barre
           if AFFICHE_VALEUR_CONTRAINTE
               Xm = (X(1) + X(2)) / 2;
               Ym = (Y(1) + Y(2)) / 2;
               Zm = (Z(1) + Z(2)) / 2;
        
               % Format du texte (tu peux changer)
               label = sprintf('%.1f', new_sigma(k));
        
               text(Xm, Ym, Zm, label, ...
                    'Color', 'k', ...
                    'FontSize', 10, ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle');
           end
        end
        
        % Colorbar
        colormap(cmap);
        c = colorbar;
        if AFFICHE_RAPPORT_CONTRAINTE
            c.Label.String = 'Rapport contrainte subie / contrainte critique';
            clim([-1 1]);
        else
            c.Label.String = 'Stress value (Pa)';
            clim([smin smax]);
        end
        
    end
    
end



end