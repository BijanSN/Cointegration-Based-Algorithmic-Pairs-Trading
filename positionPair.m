function p = positionPair(spreads)

    ncol = size(spreads,2);
    nDays = size(spreads,1);
    
    p = zeros(nDays, ncol);
    

    for i=1:ncol
        
        y = spreads(1:end-1,i);
        t = spreads(2:end,i);
        
        cb = mean(spreads(:,i));
        ub = cb + 2 * std(spreads(:,i));
        lb = cb - 2 * std(spreads(:,i));
        
        for j=2:nDays
            
            if (p(j-1,i) == 0) % No position
                
                if (y(j-1) > ub && t(j-1) < ub)
                    p(j,i) = -1;
                elseif (y(j-1) < lb && t(j-1) > lb)
                    p(j,i) = 1;
                end;
                
            elseif (p(j-1,i) == 1) % Buy greater sell the lower
                
                if (y(j-1) < cb && t(j-1) > cb)
                    p(j,i) = 0;
                else
                    p(j,i) = 1;
                end;
            
            else % p(j-1) == -1 Buy the lower sell the greater
            
                if (y(j-1) > cb && t(j-1) < cb)
                    p(j,i) = 0;
                else
                    p(j,i) = -1;
                end;
                
            end;
            
        end;
        
    end;

end