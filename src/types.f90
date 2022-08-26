module types

    use stdlib_sorting, only: sort

    implicit none

    private :: bundeslands_eastern, &
               bundeslands_western

    character(50), parameter :: bundeslands_eastern(6) = [  &
        character(50) :: 'Berlin-Ost',                      &
        'Brandenburg',                                      &
        'Mecklenburg-Vorpommern',                           &
        'Sachsen',                                          &
        'Sachsen-Anhalt',                                   &
        'Thüringen' ]
    character(50), parameter :: bundeslands_western(11) = [ &
        character(50) :: 'Baden-Württemberg',               &
        'Bayern',                                           &
        'Berlin-West',                                      &
        'Bremen',                                           &
        'Hamburg',                                          &
        'Hessen',                                           &
        'Niedersachsen',                                    &
        'Nordrhein-Westfalen',                              &
        'Rheinland-Pfalz',                                  &
        'Saarland',                                         &
        'Schleswig-Holstein' ]

    public :: Bundesland,           &
              ContributionsParams,  &
              ContributionLevels,   &
              StatutoryDefaults,    &
              all_bundeslands

    type :: StatutoryDefaults
        real(8) :: kv                 = 0.073 ! 14.6% in total, half paid by employer = 7.3%
        real(8) :: pv_outside_sachsen = 0.01525 ! 3.05 % in total, half paid by employer = 1.525% outside of Sachsen
        real(8) :: pv_inside_sachsen  = 0.01025 ! 3.05 % in total, employer = 1.025% when in Sachsen
        real(8) :: rv                 = 0.093 ! 18.6% in total, half paid by employer = 9.3%
        real(8) :: av                 = 0.012 ! 2.4% in total, half paid by employer = 1.2%
        real(8) :: u3_2022            = 0.0009 ! statutory 0.09% in 2022
        real(8) :: u3_2023            = 0.0015 ! statutory 0.15% in 2023
    end type

    type :: Bundesland
        character(50) :: name
    contains
        procedure, pass(self) :: is_sachsen
        procedure, pass(self) :: is_west
        procedure, pass(self) :: region_string
    end type

    type :: ContributionsParams
        type(Bundesland) :: bundesland
        real(8) :: kv_personal, u1, u2
        integer(4) :: year
    end type

    type :: ContributionLevels
        type(StatutoryDefaults) :: statutory = StatutoryDefaults()
        type(ContributionsParams) :: params
    contains
        procedure, pass(self) :: kv
        procedure, pass(self) :: pv
        procedure, pass(self) :: rv
        procedure, pass(self) :: av
        procedure, pass(self) :: u1
        procedure, pass(self) :: u2
        procedure, pass(self) :: u3
        procedure, pass(self) :: cutoff_kv
        procedure, pass(self) :: cutoff_pv
        procedure, pass(self) :: cutoff_rv
        procedure, pass(self) :: cutoff_av
    end type

contains

    pure character(1000) function all_bundeslands() result(output)
        ! The dimension here isn't optimal but list of Bundelands is the
        ! least variable setting in this program.
        ! --------------------------------------------------------------
        ! Instead of doing:
        !   character(50), dimension(17) :: arr, I can do:
        !   character(50), allocatable :: arr(:)
        ! There's a second method for declaring an array with fixed size:
        !   character(50) :: arr(17)
        character(50), allocatable :: arr(:)
        integer(4) :: i
        ! merge arrays
        ! ------------
        allocate(character(50) :: arr(size(bundeslands_western) + size(bundeslands_eastern)))
        arr(1:size(bundeslands_western)) = bundeslands_western
        arr(size(bundeslands_western)+1:)  = bundeslands_eastern
        ! then sort the resulting array
        ! -----------------------------
        call sort(arr)
        ! and join individual items with commas
        ! -------------------------------------
        output = trim(arr(1)) ! initialize the string, data is garbled if we don't do this...
        do i=2, size(arr), 1
            output = trim(output) // ',' // trim(arr(i))
        end do
        deallocate(arr)
    end function all_bundeslands

    ! ----------------
    ! Bundesland type:
    ! ----------------

    pure logical function is_sachsen(self)
        ! This function returns .true. if given bundesland is a Western bundesland,
        ! .false. otherwise.
        class(Bundesland), intent(in) :: self
        is_sachsen = self%name == 'Sachsen'
    end function is_sachsen

    pure logical function is_west(self)
        class(Bundesland), intent(in) :: self
        is_west = any(bundeslands_western == self%name)
    end function is_west

    pure character(4) function region_string(self)
        class(Bundesland), intent(in) :: self
        region_string = "West"
        if (.not.self%is_west()) then
            region_string = "East"
        end if
    end function region_string

    ! ------------------------
    ! ContributionLevels type:
    ! ------------------------

    pure real(8) function kv(self)
        class(ContributionLevels), intent(in) :: self
        kv = self%statutory%kv + self%params%kv_personal / 2. / 100.
    end function kv

    pure real(8) function pv(self)
        class(ContributionLevels), intent(in) :: self
        pv = self%statutory%pv_outside_sachsen
        if (self%params%bundesland%is_sachsen()) then
            pv = self%statutory%pv_inside_sachsen
        end if
    end function pv

    pure real(8) function rv(self)
        class(ContributionLevels), intent(in) :: self
        rv = self%statutory%rv
    end function rv

    pure real(8) function av(self)
        class(ContributionLevels), intent(in) :: self
        av = self%statutory%av
    end function av

    pure real(8) function u1(self)
        class(ContributionLevels), intent(in) :: self
        u1 = self%params%u1 / 100.
    end function u1

    pure real(8) function u2(self)
        class(ContributionLevels), intent(in) :: self
        u2 = self%params%u2 / 100.
    end function u2

    pure real(8) function u3(self)
        class(ContributionLevels), intent(in) :: self
        u3 = self%statutory%u3_2022
        if (self%params%year >= 2023) then
            u3 = self%statutory%u3_2023
        end if
    end function u3

    pure real(8) function cutoff_kv(self)
        class(ContributionLevels), intent(in) :: self
        cutoff_kv = 4837.5
    end function cutoff_kv

    pure real(8) function cutoff_pv(self)
        class(ContributionLevels), intent(in) :: self
        cutoff_pv = 4837.5
    end function cutoff_pv

    pure real(8) function cutoff_rv(self)
        class(ContributionLevels), intent(in) :: self
        cutoff_rv = 7050.0
        if (.not. self%params%bundesland%is_west()) then
            cutoff_rv = 6750.0
        end if
    end function cutoff_rv

    pure real function cutoff_av(self)
        class(ContributionLevels), intent(in) :: self
        cutoff_av = 7050.0
        if (.not. self%params%bundesland%is_west()) then
            cutoff_av = 6750.0
        end if
    end function cutoff_av

end module types
