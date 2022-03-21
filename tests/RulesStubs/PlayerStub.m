classdef PlayerStub < handle
    properties
        color
        trainCardsHand TrainCard = TrainCard.empty
    
        destinationCardsHand DestinationTicketCard = DestinationTicketCard.empty
    
        victoryPoints = 0
    end
end