enum EditProfileState {
    case initial, initialData(ProfileUI), editing(ProfileUI, Bool), saving, saved, error(ErrorModel)
}
