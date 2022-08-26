module utils

    implicit none
    private

    public :: make_label
contains

    pure character(34) function make_label(input, indent)
        character(*), intent(in)  :: input
        integer, intent(in), optional :: indent
        make_label = input//': '
         ! suprisingly, if (present(var).and.var) leads to a segmentation fault
        if (present(indent)) then
            if (indent > 0) then
                make_label = repeat(' ', indent)//trim(make_label)
            end if
        end if
    end function make_label

end module utils
