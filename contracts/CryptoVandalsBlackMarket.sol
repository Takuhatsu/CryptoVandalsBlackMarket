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

contract CryptoVandalsBlackMarket is ERC721, ERC721Enumerable, Ownable {
    string internal nftName = "CryptoVandals";
    string internal nftSymbol = "CV";

    string _baseTokenURI;

    uint16 public constant totalVandals = 5250;
    uint16 public constant maxVandalsPurchase = 20;
    uint64 public mintPrice;
    uint64 public legacyMintPrice;

    uint256 private mintedVandals;

    bool public legacyActive;

    modifier legacyIsActive() {
        require(legacyActive, "Legacy minting is not active");
        _;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // Tracking of legacy minted tokens
    struct LegacyMintInfo {
        uint256[] tokens;
    }

    mapping(address => LegacyMintInfo) legacyMintInfo;

    using Strings for uint256;
    using SafeMath for uint256;

    constructor() ERC721(nftName, nftSymbol) {}

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    // Toggle the state of legacy minting
    function toggleLegacyActivation() external onlyOwner {
        legacyActive = !legacyActive;
    }

    // Set the mint price for regular minting
    function setMintPrice(uint64 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }

    // Set the mint price for legacy minting
    function setLegacyMintPrice(uint64 newPrice) external onlyOwner {
        legacyMintPrice = newPrice;
    }

    function getVandal(uint16 numVandals) external payable {
        require(
            numVandals > 0 && numVandals <= maxVandalsPurchase,
            "Invalid number of Vandals to mint"
        );
        require(
            totalSupply().add(numVandals) <= totalVandals,
            "All Vandals are minted"
        );
        require(
            msg.value == numVandals * mintPrice,
            "Incorrect Ether value sent"
        );

        for (uint16 i = 0; i < numVandals; i++) {
            uint256 tokenId = _tokenIdCounter.current() + 250; // Start from ID 250
            require(tokenId < totalVandals, "Token ID out of range");
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }
    }

    function legacyGetVandal(uint256[] calldata tokenIds)
        external
        payable
        legacyIsActive
    {
        LegacyMintInfo storage info = legacyMintInfo[msg.sender];

        require(
            msg.value == tokenIds.length * legacyMintPrice,
            "Incorrect Ether value sent"
        );

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] < 250, "Invalid token ID for legacy minting");
            _safeMint(msg.sender, tokenIds[i]);
        }

        info.tokens = tokenIds;
    }

    function vandalsRemained() public view returns (uint256) {
        uint256 vandalsMinted = totalSupply();
        uint256 _vandalsRemained = uint256(totalVandals).sub(vandalsMinted);
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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}