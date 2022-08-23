program check

    use german_salary, only: is_west

implicit none

    character(50), parameter :: west_bundesland = 'Bayern'
    character(50), parameter :: east_bundesland = 'Sachsen'

    if (.not.is_west(west_bundesland)) then
        write(*,*)'FAILED: expected ',trim(west_bundesland),' as West'
        stop 1
    end if

    if (is_west(east_bundesland)) then
        write(*,*)'FAILED: ',trim(east_bundesland),' was West but should have been East'
        stop 2
    end if

end program check
