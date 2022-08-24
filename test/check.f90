program check

    use configs, only: bundesland_is_west

implicit none

    character(50), parameter :: west_bundesland = 'Bayern'
    character(50), parameter :: east_bundesland = 'Sachsen'

    if (.not.bundesland_is_west(west_bundesland)) then
        write(*,*)'FAILED: expected ',trim(west_bundesland),' as West'
        stop 1
    end if

    if (bundesland_is_west(east_bundesland)) then
        write(*,*)'FAILED: ',trim(east_bundesland),' was West but should have been East'
        stop 2
    end if

    print *, repeat(' ', 2)

end program check
