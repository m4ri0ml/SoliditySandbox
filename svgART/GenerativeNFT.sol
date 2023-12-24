pragma solidity ^0.8.0;

import "../utils/ERC721URIStorage.sol";
import "../utils/Base64.sol";

contract GenerativeSVG is ERC721URIStorage {
    uint256 public tokenCounter;

    constructor() ERC721("GenerativeSVG", "GSVG") {
        tokenCounter = 0;
    }

    function createCollectible() public returns (uint256) {
        uint256 newItemId = tokenCounter;
        string memory tokenURI = generateTokenURI(newItemId);

        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        tokenCounter += 1;
        return newItemId;
    }

    function generateTokenURI(uint256 tokenId) internal view returns (string memory) {
        string memory svg = generateSVG(tokenId);
        string memory svgBase64Encoded = encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked("data:image/svg+xml;base64,", svgBase64Encoded));
    }

    function generateSVG(uint256 tokenId) internal view returns (string memory) {
        uint256 rand = pseudoRandomNumber(tokenId);

        // Random colors
        string memory color1 = randomColor(rand, 0);
        string memory color2 = randomColor(rand, 1);
        string memory color3 = randomColor(rand, 2);

        // Random positions and sizes for gradients
        (string memory gradPos1, string memory gradSize1) = randomGradientAttributes(rand, 3);
        (string memory gradPos2, string memory gradSize2) = randomGradientAttributes(rand, 4);
        (string memory gradPos3, string memory gradSize3) = randomGradientAttributes(rand, 5);

        // Random border radius
        string memory borderRadius = toString(rand % 101);

            // Construct SVG with randomized attributes
            string memory svg = string(abi.encodePacked(
            "<svg xmlns='http://www.w3.org/2000/svg' width='200' height='200'>",
                "<defs>",
                    "<radialGradient id='grad1' ", gradPos1, " r='", gradSize1, "'>",
                        "<stop offset='0%' style='stop-color:", color1, ";stop-opacity:1' />",
                        "<stop offset='100%' style='stop-color:", color2, ";stop-opacity:0' />",
                    "</radialGradient>",
                    "<radialGradient id='grad2' ", gradPos2, " r='", gradSize2, "'>",
                        "<stop offset='0%' style='stop-color:", color2, ";stop-opacity:1' />",
                        "<stop offset='100%' style='stop-color:", color3, ";stop-opacity:0' />",
                    "</radialGradient>",
                    "<radialGradient id='grad3' ", gradPos3, " r='", gradSize3, "'>",
                        "<stop offset='0%' style='stop-color:", color3, ";stop-opacity:1' />",
                        "<stop offset='100%' style='stop-color:", color1, ";stop-opacity:0' />",
                    "</radialGradient>",
                "</defs>",
                "<rect width='200' height='200' fill='url(#grad1)' rx='", borderRadius, "' ry='", borderRadius, "'/>",
                "<rect width='200' height='200' fill='url(#grad2)' rx='", borderRadius, "' ry='", borderRadius, "'/>",
                "<rect width='200' height='200' fill='url(#grad3)' rx='", borderRadius, "' ry='", borderRadius, "'/>",
            "</svg>"
        ));
        return svg;
    }

    function randomColor() internal pure returns (string memory) { 
        uint256 red = (uint256(keccak256(abi.encode(rand, salt))) % 256);
        uint256 green = (uint256(keccak256(abi.encode(rand, salt + 1))) % 256);
        uint256 blue = (uint256(keccak256(abi.encode(rand, salt + 2))) % 256);
        return string(abi.encodePacked("rgb(", toString(red), ",", toString(green), ",", toString(blue), ")"));
    }

    function randomGradientAttributes() internal pure returns (string memory, string memory) {
        uint256 cx = (uint256(keccak256(abi.encode(rand, salt))) % 100);
        uint256 cy = (uint256(keccak256(abi.encode(rand, salt + 1))) % 100);
        uint256 r = (50 + (uint256(keccak256(abi.encode(rand, salt + 2))) % 50));
        return (string(abi.encodePacked("cx='", toString(cx), "%' cy='", toString(cy), "%'")), toString(r));
    }

    function pseudoRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, tokenCounter)));
    }   
}
