classdef DestinationTicketBonusRules < DefaultRules
    %DestinationTicketBonusRules
    %   Awards a bonus for each destination ticket completed

    methods
        function points = getDestinationTicketPoints(rules, ticket, completed)
            %getDestinationTicketPoints Return the number of victory points the given
            %destination ticket is worth
            if completed
                % add points if ticket was completed, plus bonus
                points = ticket.pointValue + 7;
            else
                % subtract points if ticket was not completed
                points = -ticket.pointValue;
            end
       
        end
    end
end