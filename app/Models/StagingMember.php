<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StagingMember extends Model
{
    protected $table='staging_members';
    public $fillable = ['loan_account_number'];

}
