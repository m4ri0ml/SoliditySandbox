pragma solidity ^0.8.0;

import "../utils/ERC721.sol";
import "../utils/Base64.sol";
import "../utils/Strings.sol";

contract RandomSVG is ERC721URIStorage {
    uint256 private _tokenIds;

    string[] private cars = ["Porsche 911", "Volkswagen Golf", "Honda Civic", "Ferrari F40", "Nissan Skyline", "Fiat Panda", "Opel Vectra"];

    constructor() ERC721("RandomSVG", "RSVG") {}

    function mintRandomSVG(address recipient) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);

        uint256 randomNumber = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, newItemId))) % 100) + 1;
        string memory randomWord = cars[(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, newItemId))) % cars.length)];

        string memory svg = string(abi.encodePacked("<svg xmlns='http://www.w3.org/2000/svg' width='200' height='200'><text x='10' y='20' class='small'>#", 
                          toString(randomNumber), "</text><text x='10' y='40' class='small'>", randomWord, "</text></svg>"));
        string memory base64EncodedSVG = encode(bytes(svg));
        string memory imageURI = string(abi.encodePacked("data:image/svg+xml;base64,", base64EncodedSVG));

        _setTokenURI(newItemId, imageURI);

        return newItemId;
    }
}