pragma solidity ^0.5.0;

import '../interface/IValidator.sol';
import '../interface/ILiability.sol';

contract ConfirmValidator is IValidator {
    address public validator;

    constructor(address _validator) public {
        validator = _validator;
    }

    function isValidator(address _validator) external returns (bool) {
        return _validator == validator;
    }
}
