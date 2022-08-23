module configs

    use stdlib_sorting, only: sort

    implicit none
    private

    public :: t_contribution_levels
    public :: all_bundeslands
    public :: get_contributions
    public :: western

    type :: t_contribution_levels
        character(50) :: bundesland
        real(8) :: kv
        real(8) :: kv_personal
        real(8) :: pv
        real(8) :: rv
        real(8) :: av
        real(8) :: u1
        real(8) :: u2
        real(8) :: u3
    end type

contains

    pure function all_bundeslands() result(output)
        ! The dimension here isn't optimal but list of Bundelands is the
        ! least variable setting in this program.
        ! --------------------------------------------------------------
        character(50), dimension(17) :: arr
        character(1000) :: output
        integer(4) :: i
        ! merge arrays
        ! ------------
        arr(1:11) = western()
        arr(12:) = eastern()
        ! then sort the resulting array
        ! -----------------------------
        call sort(arr)
        ! and join individual items with commas
        ! -------------------------------------
        output = trim(arr(1)) ! initialize the string, data is garbled if we don't do this...
        do i=2, size(arr), 1
            output = trim(output) // ',' // trim(arr(i))
        end do
    end function all_bundeslands

    pure function get_contributions(personal, u1p, u2p, year, bundesland) result(contributions)
        ! This function initializes social insurance contribution levels.
        ! KV, PV, RV and AV are 50% covered by employers, except of RV in Sachsen whenre employer pays little bit less.
        real(8), intent(in) :: personal, u1p, u2p
        integer(4), intent(in) :: year
        character(50), intent(in) :: bundesland
        type(t_contribution_levels) :: contributions

        ! -------------------
        ! Configure defaults:
        ! -------------------
        contributions%bundesland = bundesland
        contributions%kv = 0.073  ! 14.6% in total, half paid by employer = 7.3%
        contributions%kv_personal = personal / 2. / 100.
        contributions%pv = 0.01525 ! 3.05 % in total, half paid by employer = 1.525% outside of Sachsen
        contributions%rv = 0.093   ! 18.6% in total, half paid by employer = 9.3%
        contributions%av = 0.012   ! 2.4% in total, half paid by employer = 1.2%
        ! these depend on the Krankenkasse
        contributions%u1 = u1p / 100.
        contributions%u2 = u2p / 100.
        ! Insolvenz is the same for everyone
        contributions%u3 = 0.0009   ! 0.09%, 2022

        ! ---------------------------
        ! AV in Sachsen is different:
        ! ---------------------------
        if (bundesland == 'Sachsen') then
            contributions%pv = 0.01025 ! 3.05 % in total, employer = 1.025% when in Sachsen
        end if

        ! ------------------
        ! Year 2023 changes:
        ! ------------------
        if (year == 2023) then
            contributions%u3 = 0.0015   ! 0.15%
        end if
    end function get_contributions

    pure function western() result(out)
        character(50), dimension(11) :: out !< There are 11 Western Bundeslands.
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
    end function western

    pure function eastern() result(out)
        character(50), dimension(6) :: out !< There are 6 Eastern Bundeslands.
        out = [ character(50) :: 'Berlin-Ost', &
            'Brandenburg', &
            'Mecklenburg-Vorpommern', &
            'Sachsen', &
            'Sachsen-Anhalt', &
            'Thüringen' ]
    end function eastern



end module configs