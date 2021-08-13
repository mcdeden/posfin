<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StagingPolis extends Model
{
    protected $table='staging_polis';
    public $fillable = ['loan_account_number'];

}
