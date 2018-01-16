/*作业请提交在这个目录下*/
pragma solidity ^0.4.0;

contract EnhancedPayroll {

    struct Employee {
        address id;
        uint salaryInMonth;
        uint lastPayDay;
    }

    uint constant payDuration = 10 seconds;
    address owner;
    Employee[] employees;

    function EnhancedPayroll() {
        owner = msg.sender;
    }

    function _partialPaid(Employee employee) private {
        uint value = employee.salaryInMonth * (now - employee.lastPayDay) / payDuration;
        employee.id.transfer(value);
    }

    function _findEmployee(address employeeId) private returns(Employee, uint) {
        for (uint i = 0; i < employees.length; i++) {
            if (employees[i].id == employeeId) {
                return (employees[i], i);
            }
        }
    }

    // add
    function addEmployee(address id, uint salary) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(id);
        assert(employee.id == 0x0);
        employees.push(Employee(id, salary * 1 ether, now));
    }

    // remove
    function removeEmployee(address id) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(id);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }

    // update
    function updateEmployee(address id, uint salary) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(id);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        employee.id = id;
        employee.salaryInMonth = salary;
    }

    // addFund
    function addFund() payable returns (uint) {
        return this.balance;
    }

    // calculateRunway
    function calculateRunway() returns (uint) {
        uint total = 0;
        for (uint i = 0; i < employees.length; i ++) {
            total += employees[i].salaryInMonth;
        }
        return this.balance / total;
    }

    function hasEnoughMoney() returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() {
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);

        uint shouldPayDay = employee.lastPayDay + payDuration;
        assert(shouldPayDay < now);

        employee.lastPayDay = shouldPayDay;
        employee.id.transfer(employee.salaryInMonth);
    }
}
