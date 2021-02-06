import React from "react";

function InputField(props) {
    const { fieldName, fieldValue, setField, type, placeholder } = props;

    return (
        <input
            type={type}
            className='form-control form-control-lg'
            placeholder={placeholder}
            name={fieldName}
            value={fieldValue}
            onChange={(e) => setField(e)}
        />
    )
}

export default InputField