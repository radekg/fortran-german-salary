module configs

    use stdlib_sorting, only: sort

    implicit none
    private

    real(8), parameter :: kv = 0.073 ! 14.6% in total, half paid by employer = 7.3%
    real(8), parameter :: pv_outside_sachsen = 0.01525 ! 3.05 % in total, half paid by employer = 1.525% outside of Sachsen
    real(8), parameter :: pv_in_sachsen      = 0.01025 ! 3.05 % in total, employer = 1.025% when in Sachsen
    real(8), parameter :: rv = 0.093 ! 18.6% in total, half paid by employer = 9.3%
    real(8), parameter :: av = 0.012 ! 2.4% in total, half paid by employer = 1.2%
    real(8), parameter :: u3_2022 = 0.0009 ! statutory 0.09% in 2022
    real(8), parameter :: u3_2023 = 0.0015 ! statutory 0.15% in 2023

    public :: t_contribution_levels, &
              bundeslands_all, &
              bundeslands_eastern, &
              bundeslands_western, &
              bundesland_is_west,  &
              cutoff_kv, cutoff_pv, &
              cutoff_rv, cutoff_av, &
              get_contributions

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
        character(50), dimension(17) :: arr
        integer(4) :: i
        ! merge arrays
        ! ------------
        arr(1:11) = bundeslands_western()
        arr(12:) = bundeslands_eastern()
        ! then sort the resulting array
        ! -----------------------------
        call sort(arr)
        ! and join individual items with commas
        ! -------------------------------------
        output = trim(arr(1)) ! initialize the string, data is garbled if we don't do this...
        do i=2, size(arr), 1
            output = trim(output) // ',' // trim(arr(i))
        end do
    end function bundeslands_all

    pure function bundeslands_eastern() result(out)
        ! This function returns the list of Eastern bundeslands.
        character(50), dimension(6) :: out
        out = [ character(50) :: 'Berlin-Ost', &
            'Brandenburg', &
            'Mecklenburg-Vorpommern', &
            'Sachsen', &
            'Sachsen-Anhalt', &
            'Thüringen' ]
    end function bundeslands_eastern

    pure function bundeslands_western() result(out)
        ! This function returns the list of Western bundeslands.
        character(50), dimension(11) :: out
        out = [ character(50) :: 'Baden-Württemberg', &
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
    end function bundeslands_western

    pure logical function bundesland_is_west(bundesland) result(res)
        ! This function returns .true. if given bundesland is a Western bundesland,
        ! .false. otherwise.
        character(50), intent(in) :: bundesland
        res = any(bundeslands_western() == bundesland)
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

    pure type(t_contribution_levels) function get_contributions(personal, u1p, u2p, year, bundesland) result(res)
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
            get_contributions%u3 = u3_2023
        end if
        
    end function get_contributions

end module configs