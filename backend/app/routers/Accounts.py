from fastapi import APIRouter, HTTPException, status
from app.schema.login import LoginModel
from app.services.Accounts import create_user, loginUserCont
from app.schema.User import UserModel

router = APIRouter(tags=["Account"])

# Create Account Route
@router.post("/createAccount", response_model=UserModel)
async def createAccount(user: UserModel):
    try:
        # Create the user
        user_id = await create_user(user)
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Account creation failed"
            )

        user.id = user_id
        return user

    except HTTPException as e:
        raise e

    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )


# Login User Route
@router.post("/login")
async def loginUser(login_data: LoginModel):
    email=login_data.email
    password=login_data.password
    
    try:
        # Call login controller to verify user
        user = await loginUserCont(password, email)
        # Check if user exists
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        return user

    except HTTPException as e:
        raise e

    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )
