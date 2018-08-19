pragma solidity 0.4.24;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";


contract KrakenPriceTicker is usingOraclize {

    uint public tokenPrice;
    mapping (bytes32 => bool) public pendingQueries;

    event NewOraclizeQuery(string description);
    event NewKrakenPriceTicker(string price);

    constructor() public {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        updatePrice();
    }

    function() payable public {

    }

    function __callback(bytes32 myid, string result, bytes proof) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        require (pendingQueries[myid] == true);
        proof;
        emit NewKrakenPriceTicker(result);
        uint USD = parseInt(result);
        tokenPrice = 1 ether / USD;
        updatePrice();
        delete pendingQueries[myid];
    }

    function updatePrice() public payable {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit NewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            bytes32 queryId = oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
            pendingQueries[queryId] = true;
        }
    }
}