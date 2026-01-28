enum ProfileState {
    case initial, loading, failed(Error), data(ProfileUI)
}
