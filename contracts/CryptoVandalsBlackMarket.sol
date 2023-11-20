// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/// @title: CryptoVandals™
/// @author: Takuhatsu

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/****************************************************
 *                              CryptoVandals™ 2023 *
 ****************************************************/

contract CryptoVandalsBlackMarket is ERC721, ERC721Enumerable, Ownable {
    string internal nftName = "CryptoVandals";
    string internal nftSymbol = "CV";

    string _baseTokenURI;

    uint16 public constant totalVandals = 5250;
    uint16 public constant maxVandalsPurchase = 20;

    uint256 private mintedVandals;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    using Strings for uint256;
    using SafeMath for uint256;

    constructor() ERC721(nftName, nftSymbol) {}

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function getVandal(uint16 numVandals) public {
        require(
            numVandals <= maxVandalsPurchase,
            "You can mint up to 20 Vandals per transaction"
        );
        require(
            totalSupply().add(numVandals) <= totalVandals,
            "All Vandals are minted"
        );
        for (uint16 i = 0; i < numVandals; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }
    }

    function vandalsRemained() public view returns (uint256) {
        uint256 vandalsMinted = totalSupply();
        uint256 _vandalsRemained = uint256(totalVandals).sub(
            vandalsMinted
        );
        if (vandalsMinted == 0) {
            return totalVandals;
        } else {
            return _vandalsRemained;
        }
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        payable(owner()).transfer(balance);
    }

    // OVERRIDES

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
