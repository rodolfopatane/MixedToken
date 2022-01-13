// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract MixedToken is ERC20, Ownable {
    mapping(address => uint256) private _indexedTokensFunds;
    address[] private _indexedTokens;

    function concatString(string memory _text, string memory _newPart)
        private
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(_text, _newPart));
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    constructor(uint256 _totalSupply) ERC20("MixedToken", "MT") {
        _mint(msg.sender, _totalSupply); /* represent 100% of another tokens */
    }

    function indexToken(address _newToken, uint256 amount) public onlyOwner {
        require(
            ERC20(_newToken).balanceOf(msg.sender) > 0 &&
                ERC20(_newToken).balanceOf(msg.sender) >= amount,
            "You dont't have balance"
        );

        if (_indexedTokensFunds[_newToken] <= 0) {
            _indexedTokens.push(_newToken);
        }

        ERC20(_newToken).transferFrom(msg.sender, address(this), amount);
        _indexedTokensFunds[_newToken] = ERC20(_newToken).balanceOf(
            address(this)
        );
    }

    function getIndexedTokens() public view returns (string memory) {
        require(_indexedTokens.length > 0, "No tokens indexed");
        string memory tokensSerialized = "{";
        for (uint256 i = 0; i < _indexedTokens.length; i++) {
            tokensSerialized = concatString(
                tokensSerialized,
                string(new bytes(10))
            );
            tokensSerialized = concatString(
                tokensSerialized,
                Strings.toHexString(uint256(uint160(_indexedTokens[i])), 20)
            );
            tokensSerialized = concatString(
                tokensSerialized,
                string(new bytes(10))
            );

            tokensSerialized = concatString(tokensSerialized, ":");
            tokensSerialized = concatString(
                tokensSerialized,
                string(new bytes(10))
            );

            tokensSerialized = concatString(
                tokensSerialized,
                Strings.toString(_indexedTokensFunds[_indexedTokens[i]])
            );
            tokensSerialized = concatString(
                tokensSerialized,
                string(new bytes(10))
            );

            if (i == _indexedTokens.length - 1) {
                tokensSerialized = concatString(tokensSerialized, "} ");
            } else {
                tokensSerialized = concatString(tokensSerialized, ", ");
            }
        }
        return tokensSerialized;
    }
}
