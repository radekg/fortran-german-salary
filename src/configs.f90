module configs

    use stdlib_sorting, only: sort

    implicit none
    private :: kv, &
               pv_outside_sachsen, &
               pv_in_sachsen, &
               rv, av, &
               u3_2022, u3_2023, &
               bundeslands_eastern, &
               bundeslands_western

    real(8), parameter :: kv = 0.073 ! 14.6% in total, half paid by employer = 7.3%
    real(8), parameter :: pv_outside_sachsen = 0.01525 ! 3.05 % in total, half paid by employer = 1.525% outside of Sachsen
    real(8), parameter :: pv_in_sachsen      = 0.01025 ! 3.05 % in total, employer = 1.025% when in Sachsen
    real(8), parameter :: rv = 0.093 ! 18.6% in total, half paid by employer = 9.3%
    real(8), parameter :: av = 0.012 ! 2.4% in total, half paid by employer = 1.2%
    real(8), parameter :: u3_2022 = 0.0009 ! statutory 0.09% in 2022
    real(8), parameter :: u3_2023 = 0.0015 ! statutory 0.15% in 2023

    character(50), parameter :: bundeslands_eastern(6) = [ character(50) :: 'Berlin-Ost', &
                                        'Brandenburg', &
                                        'Mecklenburg-Vorpommern', &
                                        'Sachsen', &
                                        'Sachsen-Anhalt', &
                                        'Thüringen' ]
    character(50), parameter :: bundeslands_western(11) = [ character(50) :: 'Baden-Württemberg', &
                                        'Bayern', &
                                        'Berlin-West', &
                                        'Bremen', &
                                        'Hamburg', &
                                        'Hessen', &
                                        'Niedersachsen', &
                                        'Nordrhein-Westfalen', &
                                        'Rheinland-Pfalz', &
                                        'Saarland', &
                                        'Schleswig-Holstein' ]

    public :: t_contribution_levels, &
              bundeslands_all, &
              bundesland_is_west,  &
              cutoff_kv, cutoff_pv, &
              cutoff_rv, cutoff_av, &
              new_contributions

    type :: t_contribution_levels
        character(50) :: bundesland
        real(8) :: kv, kv_personal, &
                   pv, rv, av, &
                   u1, u2, u3
    end type

contains

    pure character(1000) function bundeslands_all() result(output)
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
    end function bundeslands_all

    pure logical function bundesland_is_west(bundesland) result(res)
        ! This function returns .true. if given bundesland is a Western bundesland,
        ! .false. otherwise.
        character(50), intent(in) :: bundesland
        res = any(bundeslands_western == bundesland)
    end function bundesland_is_west

    ! Cutoff value configurations
    pure real function cutoff_pv()
        cutoff_pv = 4837.5
    end function cutoff_pv

    pure real function cutoff_kv()
        cutoff_kv = 4837.5
    end function cutoff_kv

    pure real function cutoff_rv(bundesland)
        character(50), intent(in) :: bundesland
        cutoff_rv = 7050.0
        if (.not.bundesland_is_west(bundesland)) then
            cutoff_rv = 6750.0
        end if
    end function cutoff_rv

    pure real function cutoff_av(bundesland)
        character(50), intent(in) :: bundesland
        cutoff_av = 7050.0
        if (.not.bundesland_is_west(bundesland)) then
            cutoff_av = 6750.0
        end if
    end function cutoff_av

    pure type(t_contribution_levels) function new_contributions(personal, u1p, u2p, year, bundesland) result(res)
        ! This function initializes social insurance contribution levels.
        ! KV, PV, RV and AV are 50% covered by employers, except of RV in Sachsen whenre employer pays little bit less.
        real(8), intent(in) :: personal, u1p, u2p
        integer(4), intent(in) :: year
        character(50), intent(in) :: bundesland

        res%bundesland = bundesland
        res%kv = kv
        res%kv_personal = personal / 2. / 100.
        res%pv = pv_outside_sachsen
        res%rv = rv

        res%av = av 
        if (bundesland == 'Sachsen') then
            res%pv = pv_in_sachsen
        end if

        ! these depend on the Krankenkasse
        res%u1 = u1p / 100.
        res%u2 = u2p / 100.

        ! Insolvenz is statutory
        res%u3 = u3_2022
        if (year >= 2023) then
            res%u3 = u3_2023
        end if
        
    end function new_contributions

end module configs