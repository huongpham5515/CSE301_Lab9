use humanresourcemanagement;

-- II. Creating constraint for database:
-- 1. Check constraint to value of gender in “Nam” or “Nu”.
alter table employees
add constraint check_gender
check (gender in ('Nam', 'Nu'));

-- 2. Check constraint to value of salary > 0.
alter table employees
add constraint check_salary
check (salary > 0);


-- 3. Check constraint to value of relationship in Relative table in “Vo chong”, “Con trai”, “Con 
-- gai”, “Me ruot”, “Cha ruot”.
alter table relatives
add constraint check_relationship
check (relationship in ('Vo chong', 'Con trai', 'Con gai', 'Me ruot', 'Cha ruot'));

-- III. Writing SQL Queries.
-- 1. Look for employees with salaries above 25,000 in room 4 or employees with salaries above 
-- 30,000 in room 5.
select * from employees
where salary > 25000 and departmentID = '4' or 
salary > 30000 and departmentID = '5';

-- 2. Provide full names of employees in HCM city.
select lastName, middleName, firstName from employees
where address like '%TPHCM%';


-- 3. Indicate the date of birth of Dinh Ba Tien staff.
select dateOfBirth from employees
where lastName = 'Dinh' and middleName = 'Ba' and firstName = 'Tien';

-- 4. The names of the employees of Room 5 are involved in the "San pham X" project and this 
-- employee is directly managed by "Nguyen Thanh Tung".
select firstName from employees e
inner join assignment a on e.employeeID = a.employeeID
inner join projects p on p.projectID = a.projectID
where managerID = (select employeeID from employees where lastName = 'Nguyen' and middleName = 'Thanh'
and firstName = 'Tung') and p.projectName = 'San pham X';

-- 5. Find the names of department heads of each department.
select lastName, middleName, firstName, departmentID from employees e
where employeeID in (select managerID from department);

-- 6. Find projectID, projectName, projectAddress, departmentID, departmentName,
-- managerID, date0fEmployment.
select p.projectID, p.projectName, p.projectAddress, p.departmentID, d.departmentName,
d.managerID, d.dateOfEMployment from department d
inner join projects p on d.departmentID = p.departmentID;

-- 7. Find the names of female employees and their relatives.
select lastName, middleName, firstName, relativeName from employees e
inner join relatives r on e.employeeID = r.employeeID
where e.gender = 'Nu';

-- 8. For all projects in "Hanoi", list the project code (projectID), the code of the project lead 
-- department (departmentID), the full name of the manager (lastName, middleName, 
-- firstName) as well as the address (Address) and date of birth (date0fBirth) of the 
-- Employees.
select p.projectID, p.departmentID, e.lastName, e.middleName, 
e.firstName, e.address, e.dateOfBirth from projects p
inner join employees e on e.departmentID = p.departmentID
where employeeID in (select managerID from department)
and p.projectAddress = 'HA NOI';


-- 10. For each employee, indicate the employee's full name and the full name of the head of the 
-- department in which the employee works.
select concat(e1.lastName,' ',e1.middleName,' ', e1.firstName) as employee , 
concat(e2.lastName,' ',e2.middleName,' ', e2.firstName) as head
from employees e1 left join department d
left join employees e2 on d.managerID = e2.employeeID
on e1.departmentID = d.departmentID;


-- 11. Provide the employee's full name (lastName, middleName, firstName) and the names of 
-- the projects in which the employee participated, if any.
select e.lastName, e.middleName, e.firstName, e.employeeID, p.projectName from employees e
inner join assignment a on e.employeeID = a.employeeID
inner join projects p on p.projectID = a.projectID;


-- 12. For each scheme, list the scheme name (projectName) and the total number of hours 
-- worked per week of all employees attending that scheme.
select p.projectName, sum(a.workingHour) from projects p
inner join assignment a on p.projectID = a.projectID
group by projectName;

-- 13. For each department, list the name of the department (departmentName) and the average 
-- salary of the employees who work for that department.
select d.departmentName, avg(salary) from department d
inner join employees e on e.departmentID = d.departmentID
group by departmentName;

-- 14. For departments with an average salary above 30,000, list the name of the department and 
-- the number of employees of that department.
select d.departmentName, count(employeeID) from department d
inner join employees e on e.departmentID = d.departmentID
group by d.departmentName, d.departmentID 
having avg(salary) > 30000;

-- 15. Indicate the list of schemes (projectID) that has: workers with them (lastName) as 'Dinh' 
-- or, whose head of department presides over the scheme with them (lastName) as 'Dinh'.
select projectID from projects p
inner join department d on d.departmentID = p.departmentID
inner join employees e on e.departmentID = d.departmentID
where e.lastName = 'Dinh'
union
select projectID from projects p
inner join department d on d.departmentID = p.departmentID
inner join employees e on e.managerID = d.managerID
where e.lastName = 'Dinh';

-- 16. List of employees (lastName, middleName, firstName) with more than 2 relatives.
select concat(e.lastName,' ',e.middleName,' ', e.firstName) as employee from
employees e inner join
relatives r on e.employeeID = r.employeeID
group by employee having count(relativeName) > 2;

-- 17. List of employees (lastName, middleName, firstName) without any relatives.
select concat(e1.lastName,' ',e1.middleName,' ', e1.firstName) as employee from
employees e1 where e1.employeeID not in(
select e.employeeID from employees e inner join relatives r on
e.employeeID = r.employeeID
);

-- 18. List of department heads (lastName, middleName, firstName) with at least one relative.
select concat(e.lastName,' ',e.middleName,' ', e.firstName) as employee from
employees e inner join
department d on e.employeeID = d.managerID
inner join
relatives r on e.employeeID = r.employeeID
group by employee having count(relativeName) >= 1;


-- 19. Find the surname (lastName) of unmarried department heads.
select distinct e.lastName from employees e
inner join department d on e.employeeID = d.managerID
inner join relatives r on r.employeeID = e.employeeID
where r.relationship not in ('Vo chong', 'Con trai', 'Con gai')
union 
select e1.lastName from
employees e1 
inner join department d
on e1.employeeID = d.managerID where e1.employeeID not in(
select e.employeeID from employees e inner join relatives r on
e.employeeID = r.employeeID
);

-- 20. Indicate the full name of the employee (lastName, middleName, firstName) whose salary 
-- is above the average salary of the "Research" department.
select concat(e.lastName,' ',e.middleName,' ', e.firstName) as employee from
employees e where
salary > (select avg(salary) from employees e inner join
department d on e.departmentID = d.departmentID
where departmentName = 'Nghien Cuu');

-- 21. Indicate the name of the department and the full name of the head of the department with 
-- the largest number of employees.
select  d.departmentName, concat(e.lastName,' ',e.middleName,' ', e.firstName) as head
from department d 
inner join employees e 
on d.managerID = e.employeeID
where d.departmentID = (select departmentID  from ( 
select d1.departmentID, count(e1.employeeID) from department d1
inner join employees e1 on d1.departmentID = e1.departmentID
group by d1.departmentID 
order by count(e1.employeeID) desc limit 1
) as largest
);


-- 22. Find the full names (lastName, middleName, firstName) and addresses (Address) of 
-- employees who work on a project in 'HCMC' but the department they belong to is not 
-- located in 'HCMC'.
select distinct concat(e.lastName,' ',e.middleName,' ', e.firstName) as employee, e.address from
employees e inner join assignment a
on e.employeeID = a.employeeID
inner join projects p 
on a.projectID = p.projectID
inner join departmentaddress da
on e.departmentID = da.departmentID
where p.projectAddress = 'TP HCM' and da.address != 'TP HCM';


-- 23. Find the names and addresses of employees who work on a scheme in a city but the 
-- department to which they belong is not located in that city.
select distinct concat(e.lastName,' ',e.middleName,' ', e.firstName) as employee, e.address from
employees e inner join assignment a
on e.employeeID = a.employeeID
inner join projects p 
on a.projectID = p.projectID
inner join department d
on d.departmentID = e.departmentID
inner join departmentaddress da
on da.departmentID = d.departmentID
where p.projectAddress != da.address;

-- 24. Create procedure List employee information by department with input data 
-- departmentName.
Delimiter $$
create procedure employInfor(in departmentName varchar(10))
begin
select e.employeeID, concat(e.lastName,' ',e.middleName,' ', e.firstName) as employee 
from employees e inner join
department d on 
e.departmentID = d.departmentID
where d.departmentName = departmentName;
end;
$$


-- 25. Create a procedure to Search for projects that an employee participates in based on the 
-- employee's last name (lastName).
Delimiter $$
create procedure searchProject(in lastName varchar(20))
begin
select a.projectID, e.employeeID from assignment a
inner join employees e
on a.employeeID = e.employeeID
where e.lastName = lastName;
end;
$$


-- 26. Create a function to calculate the average salary of a department with input data 
-- departmentID.
Delimiter $$
create procedure calAverage(in departmentID int)
begin
select d.departmentName, avg(salary) from department d
inner join employees e on
d.departmentID = e.departmentID
where d.departmentID = departmentID
group by departmentName;
end;
$$

-- 27. Create a function to Check if an employee is involved in a particular project input data is 
-- employeeID, projectID
Delimiter $$
create function checkEmp(employeeID varchar(3), projectID int)
returns varchar(10)
deterministic
begin
    declare isCheck int default 0;

    select count(*) into isCheck
    from assignment a
    where a.employeeID = employeeID and a.projectID = projectID;

    if isCheck > 0
    then return 'true';
    else
    return 'false';
    end if;	
end;
$$

