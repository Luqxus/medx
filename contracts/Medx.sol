// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Medx {
    struct Record {
        bytes32 id;
        address doctor;
        uint256 date;
        string[] images;
        string recordType;
        string[] diagnosis;
    }

    struct Permission {
        uint256 expireAt;
        address patient;
    }

    mapping(address => Record[]) records;
    mapping(address => Permission[]) permissions;

    function grantWriteAccess(address to, uint256 _expiresAt) external {
        bool permissionFound = false;
        uint256 permissionIndex;
        for (uint256 _i = 0; _i < permissions[to].length; _i++) {
            if (permissions[to][_i].patient == msg.sender) {
                permissionFound = true;
                permissionIndex = _i;
                break;
            }
        }

        if (permissionFound) {
            permissions[to][permissionIndex].expireAt = block.timestamp;
        } else {
            permissions[to].push(
                Permission({expireAt: _expiresAt, patient: msg.sender})
            );
        }
    }

    function viewRecord(
        address _patient
    ) external view returns (Record[] memory) {
        bool permissionFound = false;
        for (uint256 _i = 0; _i < permissions[msg.sender].length; _i++) {
            if (
                permissions[msg.sender][_i].patient == _patient &&
                permissions[msg.sender][_i].expireAt < block.timestamp
            ) {
                permissionFound = true;
                break;
            }
        }

        require(permissionFound || _patient == msg.sender);

        return records[_patient];
    }

    function writeRecord(
        address _patient,
        address _doctor,
        string[] calldata _images,
        string calldata _recordType,
        string[] calldata _diagnosis
    ) external {
        bool permissionFound = false;

        for (uint256 _i = 0; _i < permissions[msg.sender].length; _i++) {
            if (
                permissions[msg.sender][_i].patient == _patient &&
                permissions[msg.sender][_i].expireAt < block.timestamp
            ) {
                permissionFound = true;
                break;
            }
        }

        require(permissionFound || _patient == msg.sender);
        //  timestamp
        uint256 _date = block.timestamp;

        // push new Record into patient's records
        records[_patient].push(
            Record({
                id: keccak256(abi.encode(_patient, _doctor, _date)),
                doctor: _doctor,
                date: _date,
                images: _images,
                recordType: _recordType,
                diagnosis: _diagnosis
            })
        );
    }

    function viewAnonymous() external {
        // view records without personal data for research purposes
    }
}
