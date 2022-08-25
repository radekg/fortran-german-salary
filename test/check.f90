program check

    use types, only: Bundesland

implicit none

    type(Bundesland), parameter :: west_bundesland = Bundesland('Bayern')
    type(Bundesland), parameter :: east_bundesland = Bundesland('Sachsen')

    if (.not. west_bundesland%is_west()) then
        write(*,*)'FAILED: expected ',trim(west_bundesland%name),' as West'
        stop 1
    end if

    if (east_bundesland%is_west()) then
        write(*,*)'FAILED: ',trim(east_bundesland%name),' was West but should have been East'
        stop 2
    end if

    print *, repeat(' ', 2)

end program check
