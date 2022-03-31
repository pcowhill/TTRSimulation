classdef PlayerStub < handle
    properties
        color = Color.red;
        trainCardsHand TrainCard = TrainCard.empty
    
        destinationCardsHand DestinationTicketCard = DestinationTicketCard.empty
    
        victoryPoints = 0
    end
end