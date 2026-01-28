enum EditProfileState {
    case initial, initialData(ProfileUI), editing(ProfileUI, Bool), save, saved, error(Error)
}
