use std::os::raw::{c_int, c_uchar, c_uint};

#[unsafe(no_mangle)]
pub unsafe extern "C" fn add(left: c_int, right: c_int) -> c_int {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = unsafe { add(2, 2) };
        assert_eq!(result, 4);
    }
}
